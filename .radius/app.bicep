extension radius

param environment string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource microservicesDemoApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'microservices-demo'
  properties: {
    environment: environment
  }
}

resource redisCache 'Radius.Data/redisCaches@2025-08-01-preview' = {
  name: 'redis'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/cartservice/src/Startup.cs#L36'
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: '.radius/app.bicep#L27'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
  }
}

resource adserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'adservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/adservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/adservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource cartserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'cartservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/cartservice/src?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/cartservice/src/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource checkoutserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'checkoutservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/checkoutservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/checkoutservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource currencyserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'currencyservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/currencyservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/currencyservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource emailserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'emailservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/emailservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/emailservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource frontendImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'frontend-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/frontend?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/frontend/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource paymentserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'paymentservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/paymentservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/paymentservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource productcatalogserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'productcatalogservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/productcatalogservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/productcatalogservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource recommendationserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'recommendationservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/recommendationservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/recommendationservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource shippingserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'shippingservice-image'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    build: {
      source: 'git::https://github.com/nithyatsu/microservices-demo.git//src/shippingservice?ref=38e7348eb289eb5b87c0c6e8cb19ced0449dc389'
    }
    codeReference: 'src/shippingservice/Dockerfile'
    tag: '38e7348'
  }
  dependsOn: [
    registryCreds
  ]
}

resource adserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'adservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/adservice/src/main/java/hipstershop/AdService.java#L223'
    containers: {
      adservice: {
        env: {
          PORT: {
            value: '9555'
          }
        }
        image: adserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 9555
          }
        }
      }
    }
  }
}

resource cartserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'cartservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/cartservice/src/Program.cs#L19'
    containers: {
      cartservice: {
        env: {
          REDIS_ADDR: {
            valueFrom: {
              secretKeyRef: {
                key: 'url'
                secretName: redisCache.properties.secrets.name
              }
            }
          }
        }
        image: cartserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 7070
          }
        }
      }
    }
  }
}

resource checkoutserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'checkoutservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/checkoutservice/main.go#L88'
    containers: {
      checkoutservice: {
        env: {
          CART_SERVICE_ADDR: {
            value: '${cartserviceContainer.properties.hosts.cartservice}:7070'
          }
          CURRENCY_SERVICE_ADDR: {
            value: '${currencyserviceContainer.properties.hosts.currencyservice}:7000'
          }
          EMAIL_SERVICE_ADDR: {
            value: '${emailserviceContainer.properties.hosts.emailservice}:8080'
          }
          PAYMENT_SERVICE_ADDR: {
            value: '${paymentserviceContainer.properties.hosts.paymentservice}:50051'
          }
          PORT: {
            value: '5050'
          }
          PRODUCT_CATALOG_SERVICE_ADDR: {
            value: '${productcatalogserviceContainer.properties.hosts.productcatalogservice}:3550'
          }
          SHIPPING_SERVICE_ADDR: {
            value: '${shippingserviceContainer.properties.hosts.shippingservice}:50051'
          }
        }
        image: checkoutserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 5050
          }
        }
      }
    }
  }
}

resource currencyserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'currencyservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/currencyservice/server.js#L182'
    containers: {
      currencyservice: {
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '7000'
          }
        }
        image: currencyserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 7000
          }
        }
      }
    }
  }
}

resource emailserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'emailservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/emailservice/email_server.py#L166'
    containers: {
      emailservice: {
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '8080'
          }
        }
        image: emailserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource frontendContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'frontend'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/frontend/main.go#L91'
    containers: {
      frontend: {
        env: {
          AD_SERVICE_ADDR: {
            value: '${adserviceContainer.properties.hosts.adservice}:9555'
          }
          CART_SERVICE_ADDR: {
            value: '${cartserviceContainer.properties.hosts.cartservice}:7070'
          }
          CHECKOUT_SERVICE_ADDR: {
            value: '${checkoutserviceContainer.properties.hosts.checkoutservice}:5050'
          }
          CURRENCY_SERVICE_ADDR: {
            value: '${currencyserviceContainer.properties.hosts.currencyservice}:7000'
          }
          ENABLE_PROFILER: {
            value: '0'
          }
          PORT: {
            value: '8080'
          }
          PRODUCT_CATALOG_SERVICE_ADDR: {
            value: '${productcatalogserviceContainer.properties.hosts.productcatalogservice}:3550'
          }
          RECOMMENDATION_SERVICE_ADDR: {
            value: '${recommendationserviceContainer.properties.hosts.recommendationservice}:8080'
          }
          SHIPPING_SERVICE_ADDR: {
            value: '${shippingserviceContainer.properties.hosts.shippingservice}:50051'
          }
          SHOPPING_ASSISTANT_SERVICE_ADDR: {
            value: 'shoppingassistantservice:80'
          }
        }
        image: frontendImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource paymentserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'paymentservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/paymentservice/index.js#L73'
    containers: {
      paymentservice: {
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '50051'
          }
        }
        image: paymentserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 50051
          }
        }
      }
    }
  }
}

resource productcatalogserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'productcatalogservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/productcatalogservice/server.go#L68'
    containers: {
      productcatalogservice: {
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '3550'
          }
        }
        image: productcatalogserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 3550
          }
        }
      }
    }
  }
}

resource recommendationserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'recommendationservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/recommendationservice/recommendation_server.py#L97'
    containers: {
      recommendationservice: {
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '8080'
          }
          PRODUCT_CATALOG_SERVICE_ADDR: {
            value: '${productcatalogserviceContainer.properties.hosts.productcatalogservice}:3550'
          }
        }
        image: recommendationserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource shippingserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'shippingservice'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'src/shippingservice/main.go#L56'
    containers: {
      shippingservice: {
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '50051'
          }
        }
        image: shippingserviceImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 50051
          }
        }
      }
    }
  }
}

resource frontendRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'frontend-route'
  properties: {
    environment: environment
    application: microservicesDemoApp.id
    codeReference: 'kubernetes-manifests/frontend.yaml#L126'
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          containerName: 'frontend'
          containerPort: 8080
          resourceId: frontendContainer.id
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}
