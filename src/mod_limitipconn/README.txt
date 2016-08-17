This Apache module mod_limitipconn.c, which allows web server administrators to 
limit the number of simultaneous downloads/connections permitted from a single IP address.

http://dominia.org/djao/limitipconn2.html

Very useful for limiting the amount of simultaneous connection to a website/webservice.
An usecase at yOda right now (as introduce) is our RESTful API service for the Live Auction Biddings and Buyings.
Its prevents Bots from hitting the API and causing race conditions on the logix level.


Example Apache Config:
---------------------------------------------------------------------------
# This command is always needed
ExtendedStatus On

# Only needed if the module is compiled as a DSO
LoadModule limitipconn_module lib/apache/mod_limitipconn.so

<IfModule mod_limitipconn.c>

    # Set a server-wide limit of 10 simultaneous downloads per IP,
    # no matter what.
    MaxConnPerIP 10
    <Location /somewhere>
    # This section affects all files under http://your.server/somewhere
    MaxConnPerIP 3
    # exempting images from the connection limit is often a good
    # idea if your web page has lots of inline images, since these
    # pages often generate a flurry of concurrent image requests
    NoIPLimit image/*
    </Location>

    <Directory /home/*/public_html>
    # This section affects all files under /home/*/public_html
    MaxConnPerIP 1
    # In this case, all MIME types other than audio/mpeg and video*
    # are exempt from the limit check
    OnlyIPLimit audio/mpeg video
    </Directory>
</IfModule>
---------------------------------------------------------------------------
