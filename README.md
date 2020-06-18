# Deploy Scripts for WordPress Plugins and Themes

These scripts expect the following directory structure where `your-plugin-slug` is 
the slug of your plugin in the WordPress plugin repository:

	your-plugin-slug
	 |
	 +-- git (your Git repo)
	 |   |
	 |   +-- .git
	 |   +-- readme.md
	 |   +-- your-plugin-slug.php
	 |   +-- ...
	 |
	 +-- svn (your SVN repo)
	 |   |
	 |   +-- assets
	 |   +-- trunk
	 |   +-- tags
	 |   +-- ...
	 |   
	 +-- wp-deploy (this repo)
	 |   |
	 |   +-- .git
	 |   +-- deploy.sh
	 |   +-- tag.sh
	 |   +-- ...

## How to use this

### Setup

Make sure you have `svn` installed. On a Mac you can 

```sh
brew install svn
```

See the directory structure above. Use your plugin's slug for the root directory name.

Put your plugin's code the `git` directory. Make sure this directory is actually managed by git!

```sh
git clone repository git
```

Create the SVN directory by checking out your plugin from the WordPress SVN repository.

```sh
svn co https://plugins.svn.wordpress.org/admin-bar-id-menu svn
```

Clone this [wp-deploy](https://github.com/efc/wp-deploy) directory into the root folder by using 

```sh
git clone git@github.com:efc/wp-deploy.git
```

### Deploy a new version

Edit and commit the code in the `git` folder as you normally would. You can, of course, edit it elsewhere and then just pull the revised code into this folder as well.

When you have a new release ready to go to WordPress, use the tag command to generate the SVN commit:

```sh
wp-deploy/tag.sh 1.1
```

You will need your WordPress.org login credentials to complete the SVN commit.

## Credits

Based on [kasparsd/wp-deploy](https://github.com/kasparsd/wp-deploy) which was based on ["Deploying from git to svn" by Scribu](http://scribu.net/blog/deploying-from-git-to-svn.html)

