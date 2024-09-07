## Kanban UI
http://kanban.k8s.com

## Adminer 
http://adminer.k8s.com
### Credentials
- PostgreSQL
- postgres
- kanban
- kanban
- kanban

## Swagger UI
http://kanban.k8s.com/api/swagger-ui.html#/

## ArgoCD
https://argocd.k8s.com/
### Credentials
- admin
- `k get secrets -n argocd argocd-initial-admin-secret -o jsonpath=""{.data.password} | base64 -d`