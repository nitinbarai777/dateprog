### About

Date A Programmer ("Замуж За Программиста") -  online dating for programmers with public and private profiles, online chats, tests constructor, email notifications and more. [**Date A Programmer: Post Mortem**](https://medium.com/@emironic/date-a-programmer-post-mortem-f3de04abd537) (Russian translation is [**here**](https://vc.ru/p/coder-dating)) Open sourced in January 2016 to help others save time building online dating services.

### Technology Stack

* Ruby On Rails (Ruby Version 2.1.1, Rails Version 4.1.1)
* HAML (for views)
* Mandrill (to send emails with notifications, [welcome emails, reminders etc](/doc/marketing/Email%20Triggers.pdf)  )
* Amazon AWS S3 (to store photo files from profiles)
* Amazon CloudFront (as CDN for assets)
* Heroku (hosting the application and separate server for faye chat server)
* Cloudfront (to cache assets to get high performance of the main application)
* Postgresql database
* Faye (for the realtime chat) 
* Puma web server

### License

* The code is licensed under Apache License 2.00
* Copyright &copy; 2014-2015 Evgenii Mironichev

### Credits

* Founder and Junior Developer: Evgenii Mironichev [@emironic](https://twitter.com/emironic)
* Leading Developer, Backend & Frontend, JS, Deployment, Design: Nitin Barai (http://www.sheltersoft.in) <a href="mailto:info@sheltersoft.in?subject=DATEPROG">info@sheltersoft.in</a>

#### Marketing, Emails, Analytics

* [**Email Triggers.pdf**](/doc/marketing/Email%20Triggers.pdf) - templates for 10+ emails (English, Russian) to be sent on triggers like welcome to the website, new unread message for the user, user was asked to open her private profile etc.
* [**Actions To Log - Sheet1.pdf**](/doc/analytics/Actions%20To%20Log%20-%20Sheet1.pdf) - list of events logged and sent to the external analytics systems like Google Analytics and Mixpanel

### Getting Started Instruction

#### Setting up development environment on local machine

1. clone the repo, install required bundle, copy default files, run migrations and seed data on your local machine,

```bash
~/ $ git clone git@github.com:emirn/dateprog.git
~/ $ cd dateprog
~/dateprog $ bundle install
~/dateprog $ cp config/application-default.yml config/application.yml
~/dateprog $ cp config/database-default.yml config/database.yml
~/dateprog $ cp gitignore-default .gitignore
~/dateprog $ rake db:create
~/dateprog $ rake db:reset
```

2. Now you may run the local server

```bash
~/dateprog $ rails s
```

Note: If you are using [Cloud9](https://c9.io) IDE then use the following command instead:
```bash
~/dateprog $ rails s -b $IP -p $PORT
```

**Default Users**
- admin control panel at `http://localhost:3000/admin/login` with `admin@example.com` as login and `dateprog` as password
- test users: `test@example.com` or `test1@example.com` or `test2@example.com` as login and `123456` as default password

4. Realtime chat server: clone and run your own faye rails server required for the realtime chat

````bash
~/dateprog $ cd ..
~/ $ git clone https://github.com/nitinbarai777/dateprogfaye.git
~/ $ cd dateprogfaye
````

-  create the application for Faye server on Heroku and deploy the `dateprogfaye` application to it
  
````bash
~/dateprogfaye $ git push heroku master
````

- in the local `dateprog` folder do the following
  - copy the URL of your Faye server on Heroku from browser (for example `https://YOURFAYEINSTANCE.herokuapp.com`)
  - paste that URL into the `FAYE_ENDPOINT` variable in the `config/application.yml`

4. Precompile assets for Dateprog application for the production (to run on Heroku):

````bash
~/dateprog $ RAILS_ENV=production rake assets:precompile
~/dateprog $ git add .
~/dateprog $ git commit -m "assets were precompiled for the production"
````
Amazon CloudFront note: if you have CloudFront set up then assets will be fetched from Heroku for the first time but then they will be served from `CLOUDFRONT_ENDPOINT`. When you are updating assets you may need to reset the cache in the CloudFront control panel. See [this article - see "Option 2"](http://brandonhilkert.com/blog/setting-up-a-cloudfront-cdn-for-rails/) for detailed instruction on setting up CloudFront

5. Create the application on Heroku to deploy the `dateprog` app into it
6. Setup the production environment varables for Heroku

The project uses [Figaro](https://github.com/laserlemon/figaro) gem that uses environment variables to store tokens and keys in application.yml.
Variables are stored in /config/application.yml that you **have** to update with your own generated keys and tokens.

````bash
~/dateprog $ figaro heroku:set -e production
````

7. Finally push the `dateprog` to the Heroku to run in production

````bash
~/dateprog $ git push heroku master
````

8. Run the database migration on Heroku and seed the default data

````bash
~/dateprog $ heroku run rake db:migrate
~/dateprog $ heroku run rake db:seed
````

9. See `config/application.yml` for tokens and variables you will need to set for use 3rd party services to upload photo, send emails etc

