# Kit Installation Instructions
## Development Instructions

Kit's git repository hosting capabilities make it more complicated to set up than a typical Ruby on Rails project. Luckily, some of the complexities can be avoided if you do not wish to actually host git repositories, which is usually the case for a development environment. For example, there is no need to install Gitosis or set up dedicated users for the server or git.

These instructions will walk you through setting up a development environmet for Kit. Note that you will likely need to find and follow other instructions for specific steps.

These instructions assume you are using a Linux distribution. Kit has been tested with Ubuntu and Debian. The git repository features probably will not work correctly on other operating systems. It is perfectly compatible with the Linxu subsystem for Windows, or whatever they call it now.

### 1. Create Directory Structure

A specific set of directories are required to use Kit. For a development environment, these should all be owned by your local user.

The directory structure is as follows. (Text in parenthesis describes the purpose of a directory, and is not a directory itself.)

```
/var/www/KIT/
	gitauth/
		(auth/ - skip for now.)
			(This is a clone of the gitosis admin repository)
			(gitosis.conf will be here)
			(keydir/)
				(SSH public keys go here)
		('auth.pub' public key goes here)
	gitosis/
		(This is normally the git user's home directory)
		/repositories
			(Bare repositories accessed over SSH live here)
			(gitosis-admin.git will live here too)
	readable-working-dirs/
		(Will contain readable copies of repositories, server loads files from here)
	website/
		(This is where the Rails project will go later.)
	writable-working-dirs/
		(This is where temporary copies of repositories will be edited by Kit.)

```

### 2. Dummy gitosis files

Rather than set up a git user and install Gitosis, we can just mimic its configuration repository and files.

In `/var/www/KIT/gitosis/repositories`, create a bare repository as follows:

`git init --bare gitosis-admin.git`

Then, go to `/var/www/KIT/gitauth`, and clone the bare repository we just made into `auth`:

`git clone ../gitosis/repositories/gitosis-admin.git auth`

While we are here, create a file called `auth.pub` and put something that looks like an SSH public key in there:

`test 99999999999999999999999999999 test@test.com`

Make a new directory called `keydir` inside the repository we just cloned (`auth`), as well as a new file called `gitosis.conf`.


### 3. Install Ruby 2.3.1

Kit was built on Ruby 2.3.1, which is a rather old version. I *highly* suggest using a program like `rbenv` that lets you have multiple Ruby versions installed. (If you use rbenv, you may need to install directly from GitHub or version 2.3.1 may not be available.)


### 4. Install and set up MySQL

Install MySQL. Once installed, log in and create two databases: `kit_development` and `kit_test`. Grant full privelages on both to a user called `kitdev` with the password `kitdev`. (Production servers use a real password loaded from environment variables.)

### 5. Clone the project

Clone Kit from wherever you got this file. It is intended to clone it into `/var/www/KIT/website` for consistency, but nothing actually enforces this, so install it wherever it is convenient to work on.

While Rails IDEs do exist, they are not necessary, and Kit was originally built entirely using the command line and Notepad++. Rails prints plenty of information to the console, and even provides helpful info in the browser when something goes wrong in development mode.

### 6. Install gems

A 'gem' is Ruby's name for a library. The Rails project has a list of gems it needs in a file called `Gemfile`, and a list of specific versions to be used across all developers in `Gemfile.lock`. Run the following command from the Rails project directory:

`bin/bundle install`

If it complains that Bundler isn't installed, install the Bundler gem with `gem install bundler` first.

There might be difficulties installing some gems, especially with naitive extensions. `mysql2` in particular needs some developer libraries to install. Install whatever Bundler tells you is required, and if it doesn't specify, Google can help.

This can be an annoying step, but you're almost there!

### 7. Fire up the database

Run `bin/rake db:create`. (This might be unnecessary if you created them when setting up MySQL.)

Next, run `bin/rake db:schema:load` to load the database's structure. *WARNING: IN THE FUTURE, USE `bin/rake db:migrate` TO UPDATE THE DATABASE!* `db:schema:load` will overwrite your existing database, while `migrate` will update the database with any changes it doesn't have yet. You could also use `migrate` when first installing Kit, but it would take awhile since it would go through the entire version history of the project.


### 8. Start Kit!

Everything should be in place. Run `bin/rails s` (s is short for server) to start Kit! If someting goes wrong, hopefully the console will tell you what. If you see something that looks like Puma booting up, go to `localhost:3000` in your web browser. Hopefully you will see a login page. Yay!

(Puma is Rails' default server software. It comes packaged automatically. Other software exists but hasn't been tested with Kit.)

Unfortunately, there are no users on your local copy of Kit to log in as yet. The first user on your copy of Kit will need to be created manually from the console.


### 9. Use the console to manually create a Kit account

If you haven't already, shut down your local Kit server by pressing Control+C. Then, run `bin/rails c` (c is short for console) to start Kit in console mode.

Console mode is the same as what you get by running `irb`- an interactive Ruby interpreter, but with Kit's code available and the database connected. The following will create a new admin user, skipping the normal "invitation" process:

`User.create(email: "example@example.com", admin: true, first_name: "John", last_name: "Doe", set_up: true, password: "putPasswordHere")`

You can exit the console with `exit`. Running the server will allow you to log in as this new user and start using Kit!

You will also see that an invitation email was generated. Emails aren't sent in development mode, they are just printed to a log at `logs/mailer.log`. If you wanted, you could ommit the password parameter and the set_up parameter above, then use the link from the email log to go through the normal account setup process.


### 10. Start developing!

You now have a functioning environment in which to work on Kit! In a Rails project, most of the stuff you will be editing will be in the "app" directory. If you are using Notepad++, you can open the whole directory as a "workspace", letting you access the files from a display on the side of the screen.

You will notice that the title bar is yellow in development mode. This is an intentional difference so that it is clear when you are on your local copy of Kit and when you are on the production server.

The other major differences between development and production are:
- In production, a dedicated user runs the server. The server is also run in daemon mode (the -d flag), which essentially means it runs in the background. To stop a daemon server, you must find the PID (which is conveniently noted in a file) and send it a kill command.
- Rails has extra security measures in production mode to prevent other users from running the project, accessing the database, etc. Kit has also been configured to load the production database credentials from environment variables instead of a config file.
- On a production server, gitosis would be installed in `/var/www/KIT/gitosis`, the directory would be the git user's home directory, and you would clone `gitosis-admin.git` by SSHing into the git user using a public key. (Thus, the remote would be `git@localhost:gitosis-admin.git`.)
- As a side effect of the additional users, file permissions on a production server are extremely complex, and partially rely on user groups. Be cautious editing the git systems of Kit without considering this! A testing production server in a virtual machine is a good idea if you want to dive into this.
- Rails will hot-reload changes to files as you edit them, so if you make a change all you have to do is refresh the page to see your changes. In production, changes are not reflected until a server restart. In all environments, database changes require a server shutdown followed by `bin/rake db:migrate`.
- If an error occurs, details are shown in your browser in development mode, but in production mode a simple error page is shown to avoid giving away any juicy secrets.
- Emails aren't sent in development mode, and aren't logged in production mode (to avoid giving someone with log access the ability to steal a password reset email!)
- Production server logs have different information from development servers, usually to avoid the logs getting too big.
- In a production setting, Rails will typically be behind a reverse proxy, such as by using Apache, to provide things like SSL encryption. The `public` folder can also be hosted directly in this case, bypassing Puma entirely. While Puma could do all of this alone, other programs can do the non-Rails things faster.
- In production, use `bin/rake assets:precompile` to 'precompile' static assets in the `public` folder. This does things like minifying and compressing Javascript and CSS, makes sure images are in the right places, etc. You only need to do this if certain kinds of changes were made, but it doesn't hurt to do it anyway. `bin/rake assets:clean` will clean up older stuff.

