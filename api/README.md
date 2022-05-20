# lauth-api - Library Authorization API

A REST API to provide the functionality of the legacy auth database over HTTPS,
rather than a direct connection and SQL queries from the clients.

Tools used for implementation

 - [Hanami::API](https://github.com/hanami/api) - Mini-framework handling HTTP,
   routing, and seriazliation.
 - [ROM](https://rom-rb.org/) - Ruby Object Mapper; used to build repositories,
   entities, and SQL mapping.
