# README

* `rails credentials:edit` should include the following:

```
secret_key_base: something-secret
ecobee_app_key: osomething-secret
data_encryption_key: something-secret
aws_access_id: something-secret
aws_access_key: something-secret
aws_region: us-west-2
phone: your-phone-number
```

* `bundle`, `rails db:setup`, `rails db:migrate`, and then `rails s`. Follow the prompts at the root url.