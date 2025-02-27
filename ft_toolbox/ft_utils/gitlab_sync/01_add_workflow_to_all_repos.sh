name: Backup to GitLab

on:
  push:
    branches:
      - main
      - master
  schedule:
    - cron: "0 2 * * *"

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Setup GitLab Backup
        env:
          GITLAB_TOKEN: ${{ secrets.GITLAB_TOKEN }}
          GITLAB_URL: ${{ secrets.GITLAB_URL }}
          GITLAB_NAMESPACE: ${{ secrets.GITLAB_NAMESPACE }}
        run: |
          # Configure git
          git config --global user.name "github-actions[bot]"
          git config --global user.email "github-actions[bot]@users.noreply.github.com"
          
          # Extract repository name
          REPO_NAME=${GITHUB_REPOSITORY#*/}
          
          # Function to get project ID
          get_project_id() {
            curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                "https://${GITLAB_URL}/api/v4/projects/${GITLAB_NAMESPACE}%2F${REPO_NAME}" | \
                jq -r '.id'
          }
          
          # Function to configure project settings
          configure_project() {
            local project_id=$1
            echo "Configuring project settings..."
            
            # Configure project settings
            curl -s --request PUT \
                 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                 --header "Content-Type: application/json" \
                 --data '{
                   "only_allow_merge_if_pipeline_succeeds": false,
                   "allow_merge_on_skipped_pipeline": true,
                   "restrict_user_defined_variables": false
                 }' \
                 "https://${GITLAB_URL}/api/v4/projects/${project_id}"
                 
            # Remove all existing branch protection
            curl -s --request DELETE \
                 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                 "https://${GITLAB_URL}/api/v4/projects/${project_id}/protected_branches/main"
                 
            # Add updated branch protection
            curl -s --request POST \
                 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                 --header "Content-Type: application/json" \
                 --data '{
                   "name": "main",
                   "push_access_level": 40,
                   "merge_access_level": 40,
                   "unprotect_access_level": 40,
                   "allow_force_push": true
                 }' \
                 "https://${GITLAB_URL}/api/v4/projects/${project_id}/protected_branches"
          }
          
          # Get or create project
          PROJECT_ID=$(get_project_id)
          
          if [ "$PROJECT_ID" = "null" ] || [ -z "$PROJECT_ID" ]; then
            echo "Creating new project..."
            curl -s --request POST \
                 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                 --header "Content-Type: application/json" \
                 --data "{
                   \"name\": \"${REPO_NAME}\",
                   \"path\": \"${REPO_NAME}\",
                   \"visibility\": \"private\",
                   \"initialize_with_readme\": false
                 }" \
                 "https://${GITLAB_URL}/api/v4/projects"
            
            sleep 5  # Wait for project creation
            PROJECT_ID=$(get_project_id)
          fi
          
          echo "Project ID: $PROJECT_ID"
          
          # Configure project settings
          configure_project "$PROJECT_ID"
          
          # Setup and push to GitLab
          echo "Setting up Git remote..."
          GITLAB_REPO_URL="https://oauth2:${GITLAB_TOKEN}@${GITLAB_URL}/${GITLAB_NAMESPACE}/${REPO_NAME}.git"
          git remote add gitlab "$GITLAB_REPO_URL" || git remote set-url gitlab "$GITLAB_REPO_URL"
          
          echo "Fetching from GitLab..."
          git fetch gitlab || true
          
          echo "Pushing to GitLab..."
          # Push all refs without '--mirror' to avoid hidden ref issues
          git push -f gitlab refs/remotes/origin/*:refs/heads/* refs/tags/*:refs/tags/*