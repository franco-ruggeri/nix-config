# Design

## Class Diagram

```mermaid
classDiagram
  class CommandRunner {
    <<interface>>
    +run(cmd, capture_output=False, cwd=None)
  }

  class LocalRunner {
    +run(cmd, capture_output=False, cwd=None)
  }

  class SshRunner {
    -host: str
    -user: str
    +run(cmd, capture_output=False, cwd=None)
  }

  class ZfsDataset {
    -name: str
    -runner: CommandRunner
    +snapshot_exists(snapshot_name)
    +create_snapshot(snapshot_name)
    +destroy_snapshot(snapshot_name)
    +rename_snapshot(old_name, new_name)
    +mountpoint()
    +snapshot_path(snapshot_name)
  }

  class ResticRepository {
    -path: Path
    +ensure_initialized()
    +backup_directory(path)
    +forget_prune()
    +latest_snapshot(path=None)
    +verify_recent_snapshot(max_age, path=None)
    +verify_latest_snapshot_nonzero(path=None)
    +check_metadata()
    +check_data()
  }

  class DatasetBackup {
    -dataset: ZfsDataset
    -repository: ResticRepository
    +run_backup_cycle(snapshot_name)
    +prune_repository()
    +verify_recent_snapshot(max_age)
    +verify_latest_snapshot_nonzero()
  }

  class DatasetTransfer {
    <<interface>>
    +transfer(snapshot_prefix)
  }

  class ZfsReplication {
    -source: ZfsDataset
    -destination: ZfsDataset
    +transfer(snapshot_prefix)
    +replicate(prefix)
  }

  class RsyncPull {
    -source: ZfsDataset
    -destination_path: Path
    +transfer(snapshot_prefix)
    +pull(snapshot_name)
  }

  CommandRunner <|.. LocalRunner
  CommandRunner <|.. SshRunner
  DatasetTransfer <|.. ZfsReplication
  DatasetTransfer <|.. RsyncPull

  ZfsDataset --> CommandRunner : uses
  DatasetBackup *-- ZfsDataset : dataset
  DatasetBackup *-- ResticRepository : repository
  ZfsReplication *-- ZfsDataset : source
  ZfsReplication *-- ZfsDataset : destination
  RsyncPull *-- ZfsDataset : source
```

## Architecture

The backup system is organized into three layers:

- **Domain layer**: models backup concepts and workflows.
- **Infrastructure layer**: runs shell commands locally or over SSH.
- **Application layer**: CLI entrypoints (`src`, `dst-zfs`, `dst-rsync`) that wire objects and execute flows.

This structure keeps backup logic in domain objects and isolates transport/process concerns.

## Package Organization

Source code is organized by capability:

- `homelab_backup/cli/`: command entrypoints (`src`, `dst-zfs`, `dst-rsync`) and wiring.
- `homelab_backup/backup/`: restic backup workflow (`DatasetBackup`, `ResticRepository`).
- `homelab_backup/transfer/`: dataset transfer contract and implementations (`DatasetTransfer`, `ZfsReplication`, `RsyncPull`).
- `homelab_backup/datasets/`: dataset model (`ZfsDataset`).
- `homelab_backup/execution/`: command execution backends (`CommandRunner`, `LocalRunner`, `SshRunner`).
- `homelab_backup/utils.py`: shared runtime helpers (env access, shell execution, notifications).

## Core Domain Objects

### Command runners

- `LocalRunner` executes commands on the local host.
- `SshRunner(host, user)` executes commands on a remote host via SSH.
- Both implement the same command interface (`run(cmd, capture_output=False, cwd=None)`).

Execution location is explicit through dependency injection: each dataset is constructed with one runner.

### `ZfsDataset`

`ZfsDataset(name: str, runner: CommandRunner)` represents one dataset bound to one execution location.

Responsibilities:

- Snapshot lifecycle operations: `snapshot_exists`, `create_snapshot`, `destroy_snapshot`, `rename_snapshot`.
- Dataset metadata lookup: `mountpoint`.
- Snapshot path construction: `snapshot_path(snapshot_name)`.

`ZfsDataset` is the single abstraction used by backup and transfer workflows.

### `ResticRepository`

`ResticRepository(path: Path)` encapsulates repository behavior.

Responsibilities:

- Restic environment setup (`RESTIC_REPOSITORY`, `RESTIC_CACHE_DIR`, feature flags).
- Repository bootstrap: `ensure_initialized`.
- Backup and retention: `backup_directory`, `forget_prune`.
- Verification: latest snapshot retrieval (optionally filtered by source path via `--path`), age/size checks, metadata/data checks.

A single `ResticRepository` instance may be shared across multiple `DatasetBackup` instances when all datasets back up into one shared repository.

### `DatasetBackup`

`DatasetBackup(dataset: ZfsDataset, repository: ResticRepository)` models one dataset-to-repository pairing.

Responsibilities:

- Execute backup cycle for a snapshot name (create snapshot, back up, clean up).
- Expose `prune_repository()` so the `src` CLI can apply retention after all datasets are backed up.
- Expose per-dataset repository validation, filtering restic snapshots by the dataset's snapshot path.

## Transfer Services

### `ZfsReplication`

`ZfsReplication(source: ZfsDataset, destination: ZfsDataset)` handles dataset replication.

Responsibilities:

- Determine full vs incremental transfer based on `last` snapshot presence on both sides.
- Execute `zfs send | zfs receive` pipeline.
- Rotate snapshots (`current` to `last`) on source and destination.
- Expose transfer through the shared `transfer(snapshot_prefix)` interface.

### `RsyncPull`

`RsyncPull(source: ZfsDataset, destination_path: Path)` handles rsync-based pulls.

Responsibilities:

- Create temporary source snapshot.
- Transfer from source snapshot path (`.zfs/snapshot/<name>/`).
- Ensure snapshot cleanup even on transfer failure.
- Expose transfer through the shared `transfer(snapshot_prefix)` interface.

### `DatasetTransfer`

`DatasetTransfer.transfer(snapshot_prefix: str)` is the common contract for transferring dataset snapshots.

Responsibilities:

- Provide one transfer entrypoint used by destination workflows.
- Keep transfer mode-specific mechanics (`zfs send/receive` or `rsync`) behind a common API.

## Operational Semantics

- **Backup cycle**: for each ZFS dataset: create snapshot → ensure repository → backup snapshot view → cleanup snapshot. After all datasets are backed up, apply retention once on the shared repository.
- **Replication cycle**: create source `current` -> send/receive full or incremental stream -> rotate `current` to `last` on both sides.
- **Rsync cycle**: create source snapshot -> rsync snapshot tree -> destroy temporary snapshot.

## Invariants

- Each `ZfsDataset` has exactly one runner and therefore one execution location.
- Snapshot operations are only performed through `ZfsDataset` methods.
- Restic commands are only performed through `ResticRepository` methods.
- A single `ResticRepository` is shared across all `DatasetBackup` instances; retention (`forget_prune`) is applied once after all datasets are backed up, not per dataset.
- Per-dataset snapshot verification filters by the dataset's snapshot path within the shared repository.
- Backup and transfer workflows compose domain objects; they do not issue ad-hoc dataset shell commands directly.
- Cleanup paths run on best effort and do not suppress primary operation errors.

## Error and Notification Model

- Domain operations raise failures with command context.
- CLI entrypoints aggregate failures for the run.
- Final reporting uses the existing notification mechanism.

## Runtime Contract

- CLI commands: `homelab-backup src`, `homelab-backup dst-zfs`, `homelab-backup dst-rsync`.
- Environment variables remain the runtime contract (for example `SOURCE_HOST`, `SOURCE_USER`, dataset and destination settings).

## Design Rationale

- Domain objects provide a stable API for backup behavior.
- Explicit runner injection makes local/remote semantics deterministic.
- Shared `ZfsDataset` usage across restic, ZFS replication, and rsync removes duplicated snapshot logic.
- Layer boundaries improve testability and reduce coupling between orchestration and command execution.
