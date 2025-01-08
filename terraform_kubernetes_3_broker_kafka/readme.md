### Variables:
```
There are important external ports that you can modify to suit your setup. Use these ports in `variables.tf` to access your pods: `localhost:{your_external_port}`. Check the example producer and consumer scripts in the `scripts folder`.

Additionally, the Docker image is available on Docker Hub. I’ve already pushed it: mucagriaktas/kafka:3.8.0.
```

### Apply the Terrafrom
```bash
cd terraform

terraform apply
```

