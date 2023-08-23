# openldap-docker  

builds openldap from source and serves it up on a platter.  

Current version of OpenLDAP: 2.6.6  

entrypoint will detect if a config exists. if one does, it won't touch it. if one doesn't, a generic one will be created so that slapd can run  

this was built specifically for our purposes at [ewnix](https://www.ewnix.net). Feel free to modify it to fit your needs.  

<3 u jake
