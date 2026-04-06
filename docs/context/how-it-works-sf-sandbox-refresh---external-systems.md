## Salesforce Integration Users – Sandbox Refresh Documentation
### Overview
This document outlines the Salesforce integration users, their purpose, and the steps required to reconnect integrations after a sandbox refresh.

### Integration Users
#### 1. Engineering Integration User
Purpose: Used by Engineering (Platform / Backend team) to integrate backend services with Salesforce.
Connected App: Contact Form Connected App
Integration Method: OAuth-based authentication via the connected app.
#### 2. Data Engineering Integration User
Purpose: Used by the Data Engineering team to integrate Salesforce data with the data warehouse.
External Client App: DataEng Admin Connected App
Integration Method: OAuth-based authentication via an external client application.

### Sandbox Refresh Process
When a Salesforce sandbox is refreshed, existing OAuth credentials are invalidated and integrations must be reconnected.
#### Required Actions After Sandbox Refresh
Engineering / Platform Team
Provide the Client ID and Client Secret for the Contact Form Connected App.
Confirm the backend integration is reconnected to the refreshed sandbox.
Data Engineering Team
Provide the Client ID and Client Secret for the DataEng Admin Connected App - ECA.
Confirm the data warehouse integration is successfully reconnected to the sandbox.

### Notes
Both integrations rely on OAuth and will not function until valid client credentials are reconfigured.
Coordination with both teams is required to ensure sandbox integrations are restored promptly after each refresh.
