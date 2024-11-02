# DaikiriSwift

The new coredata wrapper to easily work with it, from json to coredata and back!

### Defining a model

You simply need o inther from `Daikiri` and conform to `DaikiriId` and `Codable` protocols.

```
class Hero : Daikiri, DaikiriId, Codable {
    let id:Int

    public init(id:Int){
        self.id = id
    }
}
```

Once you have this you can simply create an instance to the core data with

```
Hero(id:1).create()
```

And you can retrieve it with

```
let hero = Hero.find(1)
```


### Queries
You can easily fetch elements from the database with the object `query` 

```
let heroes = Hero.query.whereKey("id", 1).get()
```

or you can also use another operator
```
let heroes = Hero.query.whereKey("id", ">", 4).get()
```

Other functions you can use
```
Hero.query.count()
Hero.query.max("id")
Hero.query.min("id")
Hero.query.skip(10)
Hero.query.take(4")
Hero.query.orderBy("id", ascendig: true)
```

You can combine them

```
let heroes = Hero.query
                 .whereKey("id", ">", 4)
                 .orderBy("id", ascending:false)
                 .skip(10)
                 .take(2)
                 .get()
```

### Relationships
```
belongsTo
hasMany
belongsToMany
morphTo
morphOne
morphMany
morphToMany
morphedByMany
```

