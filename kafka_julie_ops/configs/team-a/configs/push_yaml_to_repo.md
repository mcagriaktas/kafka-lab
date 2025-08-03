Think of it as a machine in your company, and another team wants to create or update a topic, etc.

```bash
cd /mnt

git clone $repo_url

git branch dev
```

Then create a YAML file, you can find an example in the `/topologies` folder.
```bash
git add .

git commit -m "first topic"

git push origin dev 
```

then check `docker logs kafka-julie` and `kafka-ui (localhost:8080)`