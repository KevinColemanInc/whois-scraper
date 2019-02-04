# whois-scraper

Stores who-is data from Verisign zone file in CSV and JSON formats

- [whois-scraper](#whois-scraper)
- [Quick start](#quick-start)
  - [Install the verisign file](#install-the-verisign-file)
  - [Run `app.rb`](#run-apprb)
- [FAQ](#faq)
  - [Where do I get the zone file?](#where-do-i-get-the-zone-file)
  - [The Verisign form requires an IP address of the server using the information. What do I put?](#the-verisign-form-requires-an-ip-address-of-the-server-using-the-information-what-do-i-put)

This uses a thread pool to quickly fetch the whois information. This writes the results of each domain to individual files in `./out` and then creates a csv file with all of the data.

If there is a failure when fetching the whois information, the status will be `failure` and the information will need to be refetched. By default, it will wait for 5 seconds and retry 2 times before marking the fetch as a failure

# Quick start

1. Clone

   `$ git clone git@github.com:KevinColemanInc/whois-scraper.git`

2. Bundle install

   `$ cd whois-scraper && bundle install`

## Install the verisign file

Install the file in the home directory with the file name

## Run `app.rb`

This parses the verisign file and use a thread pool to fetch the whois information from each domain. The whois information is stored in `./out` with each domain getting its own file. After it has fetched all of the who is information, it copys the JSON data to a single CSV file.

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

`$ ruby app.rb`

The default file name is: `zone_file`, but you can run:

`$ ruby app.rb -file zone_file`

# FAQ

## Where do I get the zone file?

The most up to date instructions are [here](https://www.verisign.com/en_US/channel-resources/domain-registry-products/zone-file/index.xhtml).

As of Feb 4, 2019: Email [tldzone@verisign-grs.com.](mailTo:tldzone@verisign-grs.com.) a completed request form found [here](https://www.verisign.com/assets/zonefile_access_request_form.pdf)

The process takes about 1 day and then you need to call their phone number to get a password to access the authorization contract. After the contract is signed, it takes up to 3 business days for them to provide the access information.

If you are like me and you are too lazy to print, sign and scan the document, you can use the MacOS Preview app to sign the document virtually, but you will need to save each page as a JPG and then recombine as a PDF again.

## The Verisign form requires an IP address of the server using the information. What do I put?

You can use my [Digital Ocean referral with free $10 credit](https://m.do.co/c/1ad1978bee9f) to setup a VPS with a static IP address for free with the $10 credit, otherwise the machine will cost $0.17 for 1 day of use.
