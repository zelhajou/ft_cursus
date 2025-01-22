# gh auth login

# Create a new token with these permissions on gitlab
# api
# read_repository
# write_repository



# Define your variables
GITLAB_TOKEN="your-gitlab-personal-access-token"
GITLAB_NAMESPACE="your-gitlab-namespace"
GITLAB_URL="https://gitlab.com" # or your GitLab instance URL

# Secret names (keys)
SECRET_NAMES=("GITLAB_TOKEN" "GITLAB_NAMESPACE" "GITLAB_URL")

# Secret values (values)
SECRET_VALUES=("$GITLAB_TOKEN" "$GITLAB_NAMESPACE" "$GITLAB_URL")

# Fetch your repositories
REPOS=$(gh repo list <your-username> --json name -q '.[].name')

# Add secrets to each repository
for REPO in $REPOS; do
  for i in "${!SECRET_NAMES[@]}"; do
    gh secret set "${SECRET_NAMES[i]}" -b"${SECRET_VALUES[i]}" -R "<your-username>/$REPO"
    echo "Added ${SECRET_NAMES[i]} to $REPO"
  done
done
