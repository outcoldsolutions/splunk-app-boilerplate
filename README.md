# Splunk Application Boilerplate

Splunk Application boilerplate, that uses docker for development.

## Requirements

* OS: we are primarily using `macOS` for development, these scripts probably will work
on Linux, but require some testing. For Windows, we can recommend using Linux
Subsystem for Windows. Patches are welcome.
* Docker. We are testing and using Docker for Mac CE (`18.03.1` at the moment).

## How to use

### Bootstrapping

> Here and below we use `appdemo` as an application name (or folder name)
> that we want to use for our application.

Create a folder for your project

```
mkdir splunk-appdemo && cd splunk-appdemo
```

Download the latest version from the master and untar it directly to the just
created folder

```
curl -L https://github.com/outcoldsolutions/splunk-app-boilerplate/archive/v1.1.tar.gz | tar xvz --strip 1
```

> You you can use the latest `https://github.com/outcoldsolutions/splunk-app-boilerplate/archive/master.tar.gz`

Initialize git

```
git init && git add . && git commit -m "Splunk Application Boilerplate"
```

Rename the application from `appboilerplate` to `appdemo` (if that an application
name you want to use) and update the files, that depends on that name

```
APPNAME=appdemo
mv appboilerplate ${APPNAME}
sed -i '' "s/appboilerplate/${APPNAME}/" Makefile .gitignore ${APPNAME}/default/app.conf hack/splunk/etc/users/admin/user-prefs/local/user-prefs.conf
```

Use your README.md file and rename the `LICENSE` to the `LICENSE-splunk-app-boilerplate`,
so you can define your `LICENSE` for the application (if you want to publish it
as an open source project).

```
cat <<- EOF > README.md
# ${APPNAME}
> built with https://github.com/outcoldsolutions/splunk-app-boilerplate
EOF
mv LICENSE LICENSE-splunk-app-boilerplate
```

Commit the changes

```
git add . && git commit -m "Renaming boilerplate to ${APPNAME}"
```

### Developing

Start Splunk

```
make splunk-up
```

It takes some time to start Splunk, append the configurations, you can follow
the progress with

```
make splunk-logs-follow
```

When it is done you can open the Splunk Web with

```
make splunk-web
```

That automatically will bring you to your application in Splunk Web, already
logged in.

#### Refreshing views and configurations

If you are modifying files locally on disk, you need to tell Splunk to refresh
them, open the refresh page

```
make splunk-refresh
```

You can also specify which parts you want to refresh with query parameters,
that will make refresh much quicker. As an example, to refresh only views, you
can open an URL

```
localhost:8000/en-US/debug/refresh?entity=data/ui/views
```

#### Have a Splunk Development License?

> You can request your Splunk Development License at [Splunk Developer License Signup](http://dev.splunk.com/page/developer_license_sign_up)

Keep your license as `hack/splunk/licenses/*.lic`, when you will start the Splunk instance,
licenses from this folder will be automatically loaded. Pattern `hack/splunk/licenses/*.lic`
included in the `.gitignore` file, so it is not going to be saved in your git repo. 

#### Configuring

You can define base configuration under `hack/splunk/etc` for your Splunk instance.
By default we predefine some configurations, like

- Cache is disabled, see [About file precedence and caching](http://dev.splunk.com/view/webframework-developapps/SP-CAAAE6T).
That allows developing applications with JavaScript code. Browser still can cache your JavaScript.
Use `make splunk-refresh` to
open a page, that let you reload dashboards and other configuration files.

- Minification is turned off for JavaScript and CSS files.

- Insecure logins are enabled, that allows us to authenticate with GET
requests (forget about login page).

- Default session timeouts increased to 30 days.

- Telemetry dialog already acknowledged.

- HTTP Event Collector is enabled with Token `00000000-0000-0000-0000-000000000001`

- `hack/splunk/etc/users/admin/user-prefs/local/user-prefs.conf` has some
default user settings for admin user, like Dark mode for SPL editor (developers
like dark themes)

You can modify all the files or add new under `hack/splunk/etc`. When you run
`make splunk-up` these files are used for bootstrapping the
Splunk instance. Changing files after `make splunk-up` does not have effect
on already bootstrapped Splunk instance, you need tear it down first `make splunk-down`
and bootstrap again `make splunk-up`.

#### Maintaining

In the `Makefile` there are two version strings that you want to update, when
updates are available. `SPLUNK_IMAGE` points to the Splunk image,
and `APPINSPECT_IMAGE` points to the image with latest AppInspect.

#### Tips&Tricks

##### When you develop dashboards with Splunk UI

You can create a symbolic link from `appdemo/default/data` to `appdemo/local/data`.

```
ln -s ../default/data appboilerplate/local/data
```

In that way, when you modify the dashboard using Splunk Web
the changes are saved to the `default` folder.

##### Using HTTP Event Collector from Vagrant

We use Vagrant a lot to test various environments. One cool hack about Vagrant
that you can access the host using IP address `10.0.2.2`, so to access you HTTP
Event Collector you can use

```
curl -k https://10.0.2.2:8088/services/collector/event/1.0 -H "Authorization: Splunk 00000000-0000-0000-0000-000000000001" -d '{"event": "hello world"}'
```

### Publishing

When it is ready for prime time, you can pack your application and upload
on [splunkbase](https://splunkbase.splunk.com)

Make sure that you move all of the configurations and changes from
`appdemo/local` to `appdemo/default`, and from `appdemo/metadata/local.meta` to
`appdemo/metadata/default.meta`, after that, you can run

> Command below deletes `appdemo/local` and `appdemo/metadata/local.meta`!

```
make app-clean
```

Verify with Splunk AppInspect that your application meets the guidelines
(not required, but preferable)

```
make app-inspect
```

Fix all the issues, if you see some (the `appboilerplate` does not meet the
guidelines)

```
make app-pack
```

Upload your application from `out/appdemo.tar.gz`.

## License

MIT License

## Contributing

We are happy to review and merge Pull Requests, but please keep in mind:

* Default configurations for Splunk instance should be minimum, but at the same
time allowing you to start quickly.
* If you aren't sure if a change should be made, open a ticket for discussion.
