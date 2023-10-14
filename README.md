## What do I hope to achive?

I've been tinkering around with different ideas when it comes to the idea of having structured data in the database without the need to utilize the typical relational-table based (normal) way you'd use postgres.

I've been messing around with things like [yunohost.org](https://yunohost.org/), my own personal json API for blog posts, and other forms of structured content using [strapi.io](https://strapi.io/) (a headless cms that utilizes postgres). The state of self-hosted software has deviated slightly from my vision of a simple easy to use utopia. On one side of the spectrum is `yunohost.org`, which offers a way to have a single server "install" other third-party self-hosted apps and using complex nginx rules route request to running ports all on the same machine, which is resource intensive, for each "app" running on the same box more ram, cpu, and storage is needed if you want to say easily host "mastodon", "wordpress", [discourse](https://www.discourse.org/), etc.

I imagine a world where you have one central postgres database, and one front-end server where you can simply "install" simple apps, blog, microblog, photo gallery, sharable bookmarks, resume, all on your own site. Your install would start out blank, and you'd be able to "install" a plugin through the UI, plugins would use their own JSON Schema, and write that schema definition to the database, then the app can interact with generic Postgres functions that are baked into the platform for things like pagination, etc. Thanks pretty much the idea. Data is a hard problem, and auto-generating an API or "models" is essential to plugin authors. The next hard problem is design, theming, etc, but I think making the schemas easy to use and auto generate an API for the plugin author or end user is essential. 

What I'm trying to eliminate is api complexity and opionated stuff. For instance https://github.com/supabase/pg_jsonschema exists which allows you to verify a json schema, and a document against a schema at the database level. No need to run AJV at runtime, no need to deal with complicated queries or transactions at runtime, all the postgres functions will handle how the system behaves and you can do what you want with it. This should consider everything from sub-schema-documents to in-json array sorting manipulation. You should be able to build a simple "todo" app with relative ease by defining a couple of schemas and linking them together.






