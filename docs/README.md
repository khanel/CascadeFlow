# Documentation Structure

This directory contains all project documentation organized into logical categories:

## 📁 Directory Structure

```
docs/
├── project/           # Project-level documentation
│   ├── overview.md   # Project overview and introduction
│   ├── architecture.md # Technical architecture decisions
│   ├── roadmap.md    # Future development plans
│   └── progress.md   # Current progress tracking
│
├── development/      # Development practices and policies
│   ├── COMMIT_CONVENTION.md    # Git commit message standards
│   ├── dependency-policy.md    # Dependency management policy
│   └── dependency-log.md       # Dependency change tracking
│
└── contributing/     # Contributing guidelines
    └── pull_request_template.md # PR template for contributors
```

## 📖 How to Use

- **New to the project?** Start with `project/overview.md`
- **Want to understand the architecture?** Read `project/architecture.md`
- **Need to track progress?** Check `project/progress.md`
- **Planning development?** Review `project/roadmap.md`
- **Contributing code?** Follow `development/COMMIT_CONVENTION.md`
- **Adding dependencies?** See `development/dependency-policy.md`
- **Opening a PR?** Use the template in `contributing/pull_request_template.md`

## 🔄 Cross-References

Documentation files reference each other. For example:
- Progress tracking references dependency policy: `docs/development/dependency-policy.md`
- Architecture decisions may reference roadmap items: `docs/project/roadmap.md`

This structure keeps related documentation together while maintaining clear separation of concerns.
