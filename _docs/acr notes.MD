Login first

```sh
az acr login -n nuvemacr 
```

Push code to ACR and build it there
```sh
az acr build -r nuvemacr -t report-downloader:latest .
```