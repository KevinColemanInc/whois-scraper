# whois-scraper

Stores whois data from Verisign zone file in CSV and JSON formats

- [whois-scraper](#whois-scraper)
- [Quick start](#quick-start)
  - [Clone](#clone)
  - [Bundle install](#bundle-install)
  - [Install the verisign file](#install-the-verisign-file)
  - [Run `app.rb`](#run-apprb)
  - [cli flags](#cli-flags)
- [FAQ](#faq)
  - [Where do I get the zone file?](#where-do-i-get-the-zone-file)
  - [The Verisign form requires an IP address of the server using the information. What do I put?](#the-verisign-form-requires-an-ip-address-of-the-server-using-the-information-what-do-i-put)
  - [What happens when the whois information fails to fetch?](#what-happens-when-the-whois-information-fails-to-fetch)
  - [This takes forever. How can I run this in the background?](#this-takes-forever-how-can-i-run-this-in-the-background)

This uses a thread pool to quickly fetch the whois information. This writes the results of each domain to individual files in `./out` and then creates a csv file with all of the data.

If there is a failure when fetching the whois information, the status will be `failure` and the information will need to be refetched. By default, it will wait for 5 seconds and retry 2 times before marking the fetch as a failure

# Quick start

## Clone

   `$ git clone git@github.com:KevinColemanInc/whois-scraper.git`

## Bundle install

   `$ cd whois-scraper && bundle install`

## Install the verisign file

Install the file in the home directory with the file name of `com.zone`.

## Run `app.rb`

This parses the verisign file and writes a unique list of domain names to `domains.txt`. Creating a unique list can take a while, so if the process is interrupted, you can safely restart it without needing to remove `domains.txt`. The nameserver information is disregarded for now and will be recaptured with the whois data.

Once `domains.txt` has been generated from the zone file, it uses a thread pool to start fetching the whois data for each domain. The whois information is stored in `./out` with each domain getting its own file. After it has fetched all of the who is information, it copys the JSON data to a single CSV file.

The JSON file has the following keys:

```
  created_on
  nameserver
  registrar
  expires_on
  registered
  domain
  status
  reason
```

Having each domain as a file, acts like a hash map of domains for easy refetching if the process needs restarting. Once all of the data is collected in the "file system hash map", a CSV file is generated to `output.csv`

`$ ruby app.rb -domain com`

The default file name is: `zone_file`, but you can run:

`$ ruby app.rb -tld=com -zone_file=com.zone -skip-unique-domains`

## cli flags
flag|meaning|
---|---|
`zone_file` | path to the zone file
`tld` | default: 'com'
`skip-unique-domains` | skips creating the domains.txt file. If you have already created it, there is no need to re-create it.
`threads` | default: 5; number of threads for whois query
`chunk_size` | default: 5_000; number of lines to read at one time. you shouldn't need to touch this.

# FAQ

## Where do I get the zone file?

The most up to date instructions are [here](https://www.verisign.com/en_US/channel-resources/domain-registry-products/zone-file/index.xhtml).

As of Feb 4, 2019: Email [tldzone@verisign-grs.com.](mailTo:tldzone@verisign-grs.com.) a completed request form found [here](https://www.verisign.com/assets/zonefile_access_request_form.pdf)

The process takes about 1 day and then you need to call their phone number to get a password to access the authorization contract. After the contract is signed, it takes up to 3 business days for them to provide the access information.

If you are like me and you are too lazy to print, sign and scan the document, you can use the MacOS Preview app to sign the document virtually, but you will need to save each page as a JPG and then recombine as a PDF again.

## The Verisign form requires an IP address of the server using the information. What do I put?

You can use my [Digital Ocean referral with free $10 credit](https://m.do.co/c/1ad1978bee9f) to setup a VPS with a static IP address for free with the $10 credit, otherwise the machine will cost $0.17 for 1 day of use.

## What happens when the whois information fails to fetch?

In `./out`, all of the failed domain json files are pre-fixed with "FAILURE#{domain}". The exception for the failure is stored in the file in the `reason` attribute

## This takes forever. How can I run this in the background?

`$ nohup ruby app.rb -tld=com -zone_file=com.zone -skip-unique-domains &> results.txt &`

This will push it a daemon and write the results to `results.txt`. You can watch the logs "live" by running:

`$ tail -f results.txt`