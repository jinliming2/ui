workflow "build and test" {
  resolves = [
    "lint",
    "test",
    "branch-filter",
  ]
  on = "push"
}

action "branch-filter" {
  uses = "actions/bin/filter@master"
  args = "branch"
}

action "install" {
  uses = "docker://node:10"
  args = "yarn install"
}

action "build" {
  uses = "docker://node:10"
  needs = ["install"]
  args = "yarn run build"
}

action "lint" {
  uses = "docker://node:10"
  needs = ["install"]
  args = "yarn run lint"
}

action "test" {
  uses = "docker://node:10"
  needs = ["build"]
  args = "yarn run test"
}

workflow "release" {
  resolves = [
    "github-release",
    "release:lint",
  ]
  on = "push"
}

action "release:tag-filter" {
  uses = "actions/bin/filter@master"
  args = "tag v*"
}

action "release:install" {
  uses = "docker://node:10"
  needs = ["release:tag-filter"]
  args = "yarn install"
}

action "release:build" {
  uses = "docker://node:10"
  needs = ["release:install"]
  args = "yarn run build"
}

action "release:lint" {
  uses = "docker://node:10"
  needs = ["release:install"]
  args = "yarn run lint"
}

action "release:test" {
  uses = "docker://node:10"
  needs = ["release:build"]
  args = "yarn run test"
}

action "release:publish" {
  needs = ["release:test"]
  uses = "docker://node:10"
  args = "sh scripts/publish.sh"
  secrets = [
    "REGISTRY_AUTH_TOKEN",
  ]
  env = {
    REGISTRY_URL = "registry.npmjs.org"
  }
}

action "github-release" {
  needs = ["release:publish"]
  uses = "docker://node:10"
  args = "sh scripts/github-release.sh"
  secrets = [
    "GITHUB_TOKEN",
  ]
}
