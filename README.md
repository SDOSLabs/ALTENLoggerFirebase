- [ALTENLoggerFirebase](#altenloggerfirebase)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Añadir al proyecto](#añadir-al-proyecto)
    - [Como dependencia en Package.swift](#como-dependencia-en-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Ejemplos de uso](#ejemplos-de-uso)

# ALTENLoggerFirebase
- Changelog: https://github.com/SDOSLabs/ALTENLoggerFirebase/blob/main/CHANGELOG.md

## Introducción
`ALTENLoggerFirebase` es una librería que se apoya en la librería `Logging` proporcionada por Apple en el [siguiente enlace](https://github.com/apple/swift-log.git). La librería `Logging` permite la creación de `Loggers` para personalizar la salida de los logs.


## Instalación

### Añadir al proyecto

Abrir Xcode y e ir al apartado `File > Add Packages...`. En el cuadro de búsqueda introducir la url del respositorio y seleccionar la versión:
```
https://github.com/SDOSLabs/ALTENLoggerFirebase.git
```

### Como dependencia en Package.swift

``` swift
dependencies: [
    .package(url: "https://github.com/SDOSLabs/ALTENLoggerFirebase.git", .upToNextMajor(from: "2.1.1"))
]
```

``` swift
//Sólo ALTENLoggerFirebaseFirebase
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "ALTENLoggerFirebaseFirebase", package: "ALTENLoggerFirebase")
    ]),
```

## Cómo se usa

Para usar esta librería hay que seguir la documentación de la librería [`Logging`](https://github.com/apple/swift-log.git). Esta librería se usará como parte de su configuración.

De forma recomendada se puede añadir un fichero al proyecto con la siguiente implementación:

``` swift
//Fichero LoggerManager.swift

import Foundation
import Logging
import ALTENLoggerFirebase
import FirebaseCrashlytics

public let logger: Logger = {
    // Init Firebase before
    var logger = Logger(label: Bundle.main.bundleIdentifier ?? "AppLogger") {
        MultiplexLogHandler([
            ALTENFirebaseLogHandler.standard(label: $0, crashlytics: Crashlytics.crashlytics())
        ])
    }
    logger.logLevel = .trace
    return logger
}()
```

- IMPORTANTE: Es obligatorio haber iniciado la [configuración de Firebase](https://firebase.google.com/docs/ios/setup?hl=es) antes de inciar el `Logger`.

De esta forma tendremos disponible en todo el proyecto la variable `logger` que se usará para realizar los logs deseados.

---

Una vez realizada la configuración de `logger` se podrá usar en cualquier parte del proyecto.

### Ejemplos de uso

``` swift
public func loadData() async {
    logger.info("Start", metadata: nil)
    defer { logger.info("End", metadata: nil) }
    //Logic here
}
```
Salida por consola
```
🟦 [Crashlytics] Send ListFilmViewModel.swift ➝ loadData() ➝ L:88
🟦 [Crashlytics] Send ListFilmViewModel.swift ➝ loadData() ➝ L:89
```
---
``` swift
public func search(searchTerm: String) async throws -> [FilmBO] {
    logger.debug("Start", metadata: ["searchTerm": "\(searchTerm)"])
    defer { logger.debug("End", metadata: ["searchTerm": "\(searchTerm)"]) }
    //Logic here
}
```
Salida por consola
```
🟩 [Crashlytics] Send ListFilmViewModel.swift ➝ loadData() ➝ L:100
🟩 [Crashlytics] Send ListFilmViewModel.swift ➝ loadData() ➝ L:101
```
---
``` swift
public func save(text: String) {
    do {
        //Logic here
        logger.info("Save success", metadata: nil)
    } catch {
        logger.error("Error on save", metadata: ["error": "\(error.localizedDescription)"])
    }
}
```
Salida por consola
```
🟦 [Crashlytics] Send ListFilmViewModel.swift ➝ loadData() ➝ L:132
🟥 [Crashlytics] Send ListFilmViewModel.swift ➝ loadData() ➝ L:134
```
---

