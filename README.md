# ListIt: Rails
A shared list API

[//]: # (* Ruby version:) 

[//]: # (* System dependencies)

[//]: # (* Configuration)

[//]: # (* Database creation)

[//]: # (* Database initialization)

[//]: # (* How to run the test suite)

[//]: # (* Services - job queues, cache servers, search engines, etc.)

[//]: # (* Deployment instructions)

## API
All calls require a valid JWT **except**:
* POST /accounts
* POST /authenticate

The JWT token MUST be sent in the AUTHORIZATION header of the request.

All calls return the appropriate http status and a JSON body that contains the following:
* status: success | error
* payload: specific returned value | error list

### Create Account
POST /accounts
#### body

* email[required]: a valid email address
* password[required]: a password that meets the following criteria:
    * at least 8 characters long
    * contains at least 1 upper case character
    * contains at least 1 lower case character
    * contains at least 1 numeric character
    * contains at least 1 special character
* first_name[optional]
* last_name[optional]
### results

#### success
* status 201
```
{
   'status': 'success',
   'payload': <JWT token>
} 
```
#### error
* status 422
```
{
    'status': 'error',
    'payload': {
        'base': <Main error>,
        <email|password>: <field-specific error>
    }
}
```
