# Data Loader Scripts

This folder contains configuration files for use with the Salesforce Data Loader or Dataloader.io.

---

## Folder Structure

```
data-loader/
├── README.md              # This file
├── field-mappings/        # .sdl field mapping files for Data Loader
└── process-configs/       # process-conf.xml files for automated Data Loader jobs
```

---

## Naming Convention

Name files after the object and operation they target:

| File | Example |
|---|---|
| Field mapping | `Account_upsert.sdl` |
| Process config | `Contact_insert_process-conf.xml` |
| Data file | `Account_upsert_data.csv` (do NOT commit data files with PII) |

> **Important:** Never commit CSV files containing real customer data or personally identifiable information (PII) to this repository.

---

## How to Use a Field Mapping File

1. Open Data Loader.
2. Choose your operation (Insert, Update, Upsert, Delete).
3. On the field mapping screen, click **Load Mapping** and select the `.sdl` file from this folder.
4. Verify the mappings are correct before proceeding.
