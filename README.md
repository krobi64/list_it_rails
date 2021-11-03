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
```http request
headers["AUTHORIZATION"] = "token <JWT token value>"
```

If the token is invalid or missing, the system will return a 401 status with the following body:
```json
{
    "status": "error",
    "payload": {
      "token": "Missing token | Invalid token"
    }
}
```

All calls return the appropriate http status and a JSON body that contains the following:
* status: success | error
* payload: specific returned value | error list

### Create Account
```http request
POST /accounts
```
#### body
```json
{
    "email": "a valid email address",
    "password": "a valid password",
    "passord_confirmation": "a valid confirmation",
    "first_name": "an optional first name",
    "last_name": "an optional last name"
}
```
* email (**required**): a valid email address
* password (**required**): a password that meets the following criteria:
    * at least 8 characters long
    * contains at least 1 upper case character
    * contains at least 1 lower case character
    * contains at least 1 numeric character
    * contains at least 1 special character
* password_confirmation (**required**): a re-typed in password value that MUST match password
* first_name (**optional**)
* last_name (**optional**)
#### results

##### success
* status 201
```json
{
   "status": "success",
   "payload": "<JWT token>"
} 
```
##### error
* status 400
```json
{
    "status": "error",
    "payload": {
        "base": "<Main error>",
        "<email|password>": "<field-specific error>"
    }
}
```

### Authenticate user
```http request
POST /authenticate
```
#### body
```json
{
    "email": "<User email>",
    "password": "<User password>"
}
```

#### responses
##### success
* status: 200
```json
{
   "status": "success",
   "payload": "<JWT token>"
} 
```
##### error
* status: 401
```json
{
    "status": "error",
    "payload": {
        "user_authentication": "invalid credentials"
    }
}
```
## Lists
### Create List
Creates a list owned by the current user.
```http request
POST /lists
```
#### body
```json
{
  "name": "List name"
}
```

#### responses
##### success
* Status: 201
* No body

##### error
* Status 400
```json
{
  "status": "error",
  "payload": {
      "name": ["can't be blank"]
  }
}
```

### Get Lists
Retrieves all lists owned by or shared with the current user. Will return an empty array if no lists meet this criteria .
```http request
GET /lists
```

#### responses
##### success
* Status: 200
```json
{
  "status": "success",
  "payload": [
    {
      "id": 1,
      "name": "List 1",
      "user": "owner1 name"
    },
    {
      "id": 23,
      "name": "List 2",
      "user": "owner3 name"
    }
  ]
}
```

##### error
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```

### Retrieve a Specific List
Returns a single list either owned by or shared with the current user.
```http request
GET /lists/:list_id
```
#### responses
##### success
* Status: 200
```json
{
  "status": "success",
  "payload": {
    "id": 1,
    "name": "List 1",
    "user": {
      "id": 1
    }
  }
}
```
##### error
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
    
}
```
### Edit List
Modify the name of an existing list owned by the current user.
```http request
PUT /lists/:list_id
```
#### body
```json
{
  "name": "New list name"
}
```
#### responses
##### success
* Status: 204
* No body

##### errors
* Status: 400
```json
{
  "status": "error",
  "payload": "Invalid Payload, refer to the api documentation"
}
```
or
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```

### Delete List
Delete a list the current user owns.
```http request
DELETE /lists/:list_id
```
#### responses
##### success
* Status: 204
* No body
##### errors
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```

## Invitations
Invitations allow a user to share a list with another. If the target user does not yet have an account, they will be 
directed to the account creation page first.
### Create Invitation
Invite a user to share a list.
```http request
POST /invites
```

```json
{
  "email": "valid email address for invited user",
  "list_id": "valid list owned by requesting user"
}
```
#### responses
##### success
* Status: 201
* No content
##### errors
* Status: 400
```json
{
  "status": "error",
  "payload": "Invalid email address"
}
```
or
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```
### Get invitations
Retrieve all invitations either sent by or sent to the current user.
This excludes any deleted invitations. To invite a user again,
create a new invitation.

```http request
GET /invites
```

#### responses
##### success
* Status: 200

```json
{
  "status": "success",
  "payload": [
    {
      "id": "invitation id",
      "list": {
        "list_id": "id",
        "name": "list name"
      },
      "sender": {
        "name": "owner_name"
      },
      "recipient": {
        "name": "recipient name"
      },
      "status": "status of invitation"
    }
  ]
}
```

### Show Invitation
Return the details of an individual invitation. This excludes any disabled Invitation. 
```http request
GET /invites/:invite_id
```

#### responses
##### success
* Status: 200

```json
{
  "status": "success",
  "payload": {
    "id": "invitation id",
    "list": {
      "list_id": "id",
      "name": "list name"
    },
    "sender": "owner_name",
    "recipient": "recipient name",
    "status": "status of invitation"
  }
}
```
##### error
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```

### Resend Invitation
Emails the invitation to the recipient again.

```http request
PUT /invites/:invite_id/resend
```

#### response
##### success
* Status: 200

```json
{
  "status": "success",
  "payload": "Invitation sent"
}
```

### Accept Invitation
Grants access to the shared list once the recipient has actively chosen to join the list.
```http request
PUT /invites/accept?token=invite_token_value
```

#### responses
##### success
* Status: 200

```json
{
  "status": "success",
  "payload": {
    "list": {
      "id": "list_id",
      "name": "name of the list",
      "created_by": "Name of the person who created the List"
    }
  }
}
```

##### error
* Status: 400

```json
{
  "status": "error",
  "payload": "Invalid token"
}
```

### Delete Invitation
The sender removes a user from a list and marks the original invitation DISABLED.
```http request
DELETE /invites/:invite_id
```
#### responses
##### success
* Status: 204
* No body

##### error

* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```
## List Items
Items are individual entries for a list that support the following actions:
* Create
* View Details
* Update
* Toggle the checked/unchecked status of the item
* Delete

### Create List Item
A list item can be created by any user with access to the list. The item will be created and added to the bottom of the list.

```http request
POST /lists/:list_id/items
```

```json
{
  "name": "item_name"
}
```
#### responses
##### success
* Status: 201

```json
{
  "id": "item_id",
  "name": "item_name",
  "order": "order position in the list",
  "state": "integer value - 0: unchecked | 1:checked",
  "token": "token for /reorder payload"
}
```

##### error
* Status 400
```json
{
  "status": "error",
  "payload": {
      "name": ["can not be blank"]
  }
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```
## Get Items for a List

Retrieve the items for a specific list. Returns the items in list order, regardless of whether the item has been checked or not.

```http request
GET /lists/:list_id/items
```

To retrieve only unchecked items:

```http request
GET /lists/:list_id/items?uc=1
```
### responses
#### success

* Status: 200

```json
[
  {
    "id": "item_id",
    "name": "the wording of the item",
    "state": "integer value - 0: unchecked | 1:checked",
    "order": "integer denoting the order placement in the list",
    "token": "token for /reorder payload"
  }
]
```

#### error
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```
## Get the details of a specific List Item

```http request
GET /lists/:list_id/items/:id
```

### responses
#### success
* Status: 200

```json
{
  "id": "item_id",
  "name": "the wording of the item",
  "order": "integer denoting the order placement in the list",
  "state": "integer value - 0: unchecked | 1:checked",
  "token": "token for /reorder payload"
}
```

#### error
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found | Item not found"
}
```

## Update a List Item

```http request
PUT /lists/:list_id/items/:id
```

```json
{
  "item": {
    "name": "Item name"
  }
}
```
  
### responses
#### success
* Status: 204
* No body

#### error
* Status: 400

```json
{
  "status": "error",
  "payload": "Invalid Payload, refer to the api documentation"
}
```

* Status: 404

```json
{
  "status": "error",
  "payload": "List not found | Item not found"
}
```

## Reordering the items in a List
```http request
PUT /lists/:list_id/items/reorder
```

An ordered list of all the list items must be included. Use an array of `item.token` in the `json` body.

```json
[
  "first_item.token",
  "second_item.token",
  "..."
]
```

### response

#### success
* Status: 200

```json
{
  "status": "success",
  "payload": [
    {
      "id": "first_item.id",
      "name": "first_item.name",
      "order": 1,
      "state": "integer value - 0: unchecked | 1:checked",
      "token": "first_item.token"
    },
    {
      "id": "second_item.id",
      "name": "second_item.name",
      "order": 2,
      "state": "integer value - 0: unchecked | 1:checked",
      "token": "token for /reorder payload"
    }
  ]
}
```

#### error
* Status: 404

```json
{
  "status": "error",
  "payload": "List not found | Item not found"
}
```
## Checking/Unchecking an Item
Marking/Unmarking as completed

```http request
PUT /lists/:list_id/items/:item_id/toggle?state=0|1
```
* state: optional (if not provided, it simply flips the state value of the persisted item)
  * 0: unchecked
  * 1: checked

### responses
#### success
* Status: 204
* No body

#### error
* Status: 404

```json
{
  "status": "error",
  "payload": "List not found | Item not found"
}
```
## Deleting an Item
```http request
DELETE /lists/:list_id/items/:item_id
```
### responses
#### success
* Status: 204
* No body

#### error
* Status: 404

```json
{
  "status": "error",
  "payload": "List not found | Item not found"
}
```


