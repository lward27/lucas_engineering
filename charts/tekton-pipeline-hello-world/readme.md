Port forward the event listener to localhost
```bash
kubectl port-forward service/el-hello-listener 8080
```

Hit the endpoint to trigger the pipeline
```bash
curl -v \
-H 'content-Type: application/json' \
-d '{"username": "Tekton123"}' \
http://localhost:8080
```