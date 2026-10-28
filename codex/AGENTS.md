# Global instructions for Codex

## Large media

Video, frame sequences, renders, datasets and other bulk files live on z840 (`/tank/archive`); this Mac is a working cache with a nearly full disk. When no one is working on such a folder, move it with `media archive <dir>`, which verifies every file on the server before it replaces the folder with a `MEDIA-ARCHIVED.md` stub. A folder holding that stub is archived: bring it back with `media fetch <dir>` instead of regenerating it. Never delete media any other way, and never write image data into logs; store the path or a hash.

Render frame sequences (Blender, ffmpeg image2) are intermediate: once a cut is encoded and accepted, archive or delete its frame folders instead of leaving them beside the final video.
