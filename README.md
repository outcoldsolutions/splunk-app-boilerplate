# Splunk Application Boilerplate

Splunk Application boilerplate, that uses docker for development.

## How to use

Fork or download the latest version from the master.

```
curl
```

## Default configuration

- Cache is disabled, see [About file precedence and caching](http://dev.splunk.com/view/webframework-developapps/SP-CAAAE6T).
That allows to develop applications with JavaScript code. There is still cache in the
browser, that you need to make sure to turn off. Use `make splunk-refresh` to
open a page, that will allow you to reload dashboards and other configuration files.

> `hack/splunk/etc/users/admin/user-prefs/local/user-prefs.conf` has 