#? Argo Workflows - K8s

##### Colours #####
GREEN := $(shell echo -e '\033[0;32m')
NC    := $(shell echo -e '\033[0m')
##### Colours #####

# Vars
REPO := $(shell git rev-parse --show-toplevel)


################################################################################

#? Create a cluster with k3d
.PHONY: apply
apply:
	. ./k3d_argocd_cluster.sh && create_cluster && install_argocd && access_argocd
	. ./k3d_argocd_cluster.sh && install_argocd_apps 


#? Destroy the cluster 
.PHONY: destroy
destroy:
	. ./k3d_argocd_cluster.sh && delete_cluster


################################################################################

# # #* Create k8s directory structure  ==> make create_dir
.PHONY: create_dir
create_dir:
	@if [ ! -d "k8s/apps/" ]; then mkdir -p k8s/apps/ \
	&& echo "==> k8s/apps/ ..."; \
	else echo  "==> k8s/apps/ $(GREEN)✓$(NC)"; fi

	@if [ ! -f ".gitattributes" ]; then echo "* text eol=lf" > .gitattributes \
	&& echo "==> .gitattributes ..."; \
	else echo "==> .gitattributes $(GREEN)✓$(NC)"; fi

	@if [ ! -f "readme.md" ]; then curl https://gist.githubusercontent.com/J0hn-B/0a8bc6d764576c1ebdcc3ecb21c3ec33/raw > readme.md \
	&& echo "==> readme.md ..."; \
	else echo "==> readme.md $(GREEN)✓$(NC)"; fi

	@if [ ! -f "k3d_argocd_cluster.sh" ]; then curl https://gist.githubusercontent.com/J0hn-B/7dad3e4d630ec7e61e36f07d7da55fd7/raw > k3d_argocd_cluster.sh \
	&& echo "==> k3d_argocd_cluster.sh ..."; \
	else echo "==> k3d_argo_cluster.sh $(GREEN)✓$(NC)"; fi

	@if [ ! -f ".gitignore" ]; then curl https://raw.githubusercontent.com/kubernetes/kubernetes/master/.gitignore > .gitignore \
	&& echo echo "==> .gitignore ..."; \
	else echo "==> .gitignore $(GREEN)✓$(NC)"; fi


# # #* Lint code  ==> make code_lint
.PHONY: code_lint
code_lint:
	@echo "$(GREEN) ==> Github Super-Linter will validate your source code.$(NC) < https://github.com/github/super-linter >"
	docker run --rm -e VALIDATE_KUBERNETES_KUBEVAL=false -e RUN_LOCAL=true \
	-v $(REPO):/tmp/lint ghcr.io/github/super-linter:slim-v4
	
ifeq ($(shell uname), Linux)
	find $(REPO) -type f -name "super-linter.log" -exec rm -f {} \;
else  
	powershell "Get-ChildItem -Recurse $(REPO) | where Name -match 'super-linter.log' | Remove-Item"
endif

