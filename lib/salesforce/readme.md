## Salesforce Integration

### Import the initial set of data
Import the CSV dump of campaign and contribution data to the database.
```sh
rake salesforce_import[./path/to/salesforce/csv/files]
```

### Setup salesforce triggers to keep the ungc site in sync.
'Triggers' must be install in Salesforce to update the ungc database when a campaign on contribution changes.
We need to run a script to install those triggers and supporting classes and we need Salesforce API access to do that.

#### update config/defaults.yml with the require info to access the API
```yaml
  salesforce:
    :host: '???.salesforce.com'
    :username: '???@????.???'
    :password: '????????????'
    :token: '????????????'
    :client_id: '????????????????????????????????????????????????????????????????????????????????????'
    :client_secret: '???????????????????'
```
The following describees how to get that info:

#### host, username and password
You should have these already.

#### token
```
Personal Setup
  My Personal Information
    Reset Security token
```

Your token will show up in an email

#### client_id and client_secret
```
App Setup
  Create
    Apps
      Connected Apps
        Connected App Name: UNGCSync
        API Name: UNGCSync
        Contact Email: <email>
        Enable OAuth Settings
        Callback URL: https://www.unglobalcompact.org/oauth_callback
        Select OAuth Scope: Access and manage your data (api)
```
* client_id is 'Consumer Key'
* client_secret is 'Consumer Secret' click to reveal

#### allowing remote access to the unglobalcompact site
```
Administration Setup
  Security Controls
    Remote Site Settings
      New Remote Site
        Remote Site Name: UNGCSite
        Remote Site URL: https://www.unglobalcompact.org
```

#### create the supporting salesforce object
```
App Setup
  Create
    Objects
      New Custom Object
        Label: UNGCSync
        Plural Label:  UNGCSyncs
        Object Name: UNGCSync
        Record Name: UNGCSync Name
        Save
      Custom Fields & Relationships
        Campaign
          Data Type: Lookup Relationship
          Related To: Campaign
          Field Label: Campaign
          Field Name: Campaign
        Opportunity  Lookup(Opportunity)
          Data Type: Lookup Relationship
          Related To: Opportunity
          Field Label: Opportunity
          Field Name: Opportunity
        Type
          Data Type: Number
          Field Label: Type
          Length: 1
          Decimal Places: 0
          Field Name: Type
        DeletedId
          Data Type: Text
          Field Label: DeletedId
          Length: 18
          Field Name: DeletedId
        Errors
          Data Type: Text
          Field Label: Errors
          Length: 255
          Field Name: Errors
```

#### run the installer
```sh
# this will install classes and triggers
rake salesforce_install
```

#### tools
The following commands can be used to show what is currently in the failed sync queue and can be used to clear it out respectively.
```sh
rake salesforce_show_pending
```
```sh
rake salesforce_clear_pending
```

#### Adding fields
In order to add a field to the sync process a number of steps must be taken. As an example, we'll add Forecast Category to Contributions. Contributions are referred to as 'Opportunities' on the salesforce side.

##### Add the field to the Contributions model in rails.
  Create a migration, etc...

##### Add the field to the UngcOpportunityUpsert so that when Contributions are created or updated, they are sent to the rails app
  Edit lib/salesforce/classes/UngcOpportunityUpsert.apex
```java
  ...
    private List<Opportunity> load() {
    return [
      SELECT  Id,
              Account.AccountNumber,
              CampaignId,
              Invoice_Code__c,
              Recognition_Amount__c,
              Amount,
              StageName,
              CloseDate,
              Payment_type__c,
              ForecastCategory,     <-- our new field
              IsDeleted
      FROM    Opportunity
      WHERE   Id in :ids
    ];
  }
  ...
```

##### Add the field to the UngcPendingOpportunityJobs model. When an Opportunity sync fails, we need to load the fields from the db.
  Edit lib/salesforce/classes/UngcPendingOpportunityJobs.apex
```java
  ...
  public override List<UngcSync__c> serialize() {
    if(this.syncs == null) {
      this.syncs = [
        SELECT  Opportunity__c,
                Type__c,
                Opportunity__r.Account.AccountNumber,
                Opportunity__r.CampaignId,
                Opportunity__r.Invoice_Code__c,
                Opportunity__r.Recognition_Amount__c,
                Opportunity__r.Amount,
                Opportunity__r.StageName,
                Opportunity__r.CloseDate,
                Opportunity__r.Payment_type__c,
                Opportunity__r.IsDeleted,
                Opportunity__r.ForecastCategory     <-- our new field
        FROM    UNGCSync__c
        WHERE   Type__c = :OPPORTUNITY_UPSERT
        OR      Type__c = :OPPORTUNITY_DELETE
      ];
    }
    return this.syncs;
  }
  ...
```

##### re-install the apex classes
```sh
  rake salesforce_install
```

