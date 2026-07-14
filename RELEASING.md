# Releasing

This project distributes through three credential-free channels for consumers:

1. **Maven Central** (`io.github.chirstius:dataweave-slack-blockkit`) — the durable, default-repo,
   immutable path. Automated by [`.github/workflows/release.yml`](.github/workflows/release.yml).
2. **JitPack** (`com.github.chirstius:dataweave-slack-blockkit`) — builds on demand from any git
   tag; no setup beyond a public repo + [`jitpack.yml`](jitpack.yml).
3. **Copy-in** — the raw `.dwl` files under `src/main/dw/slack`.

`main` is continuously built and tested by [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

---

## JitPack (works immediately)

Once this repo is public on GitHub and a tag exists, JitPack can build it with zero further
setup. The first time anyone requests `com.github.chirstius:dataweave-slack-blockkit:<tag>`,
JitPack builds and caches it. Nothing for you to do but push a tag. Verify at
`https://jitpack.io/#chirstius/dataweave-slack-blockkit`.

---

## Maven Central — one-time setup

You only do this once. It requires a Sonatype account and a GPG signing key; neither is tied to
any Anypoint organization.

### 1. Claim the `io.github.chirstius` namespace

- Sign in to the [Central Portal](https://central.sonatype.com/) with GitHub.
- Register the namespace **`io.github.chirstius`**. Central verifies ownership by having you
  create a temporary public GitHub repo whose name it dictates (proves you control the
  `chirstius` GitHub account). This is why the `groupId` is `io.github.chirstius`.

### 2. Generate a user token

- In the Central Portal, under your account, **Generate User Token**. You get a username and a
  password (these are NOT your login). These become the `CENTRAL_TOKEN_*` secrets below.

### 3. Create a GPG signing key

Central requires every artifact to be GPG-signed.

```bash
gpg --gen-key                                   # name + email (chuck.hirstius@gmail.com)
gpg --list-secret-keys --keyid-format=long      # note the key id
gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>   # publish the public key
gpg --armor --export-secret-keys <KEY_ID>       # the ARMORED PRIVATE KEY -> GPG_PRIVATE_KEY secret
```

Publishing the public key to a keyserver is required so Central can verify the signatures.

### 4. Add GitHub repository secrets

In the GitHub repo: **Settings -> Secrets and variables -> Actions -> New repository secret**:

| Secret | Value |
|---|---|
| `CENTRAL_TOKEN_USERNAME` | user-token username from step 2 |
| `CENTRAL_TOKEN_PASSWORD` | user-token password from step 2 |
| `GPG_PRIVATE_KEY` | the full armored private key from step 3 (incl. the BEGIN/END lines) |
| `GPG_PASSPHRASE` | the passphrase for that key |

---

## Cutting a release

1. Bump `<version>` in [`pom.xml`](pom.xml) to the release version (e.g. `1.0.1`), commit, push.
2. Create a **GitHub Release** with a tag like `v1.0.1` (or run the *Release to Maven Central*
   workflow manually via **workflow_dispatch**).
3. The `release` workflow signs the artifacts and uploads them to the Central Portal.
4. `autoPublish` is `true` in the pom's `release` profile, so once Central validates the upload it
   publishes automatically — no manual click. `waitUntil=published` makes the workflow block until
   it goes live, so a validation failure fails the workflow. (Set `autoPublish` to `false` to go
   back to staged deployments you publish by hand in the Portal.)
5. After Central processes it (usually minutes), the artifact is live at
   `https://repo1.maven.org/maven2/io/github/chirstius/dataweave-slack-blockkit/`.

### Local dry run

You can exercise the signing/build locally without publishing:

```bash
mvn -Prelease clean verify -Dgpg.skip=false     # builds + signs; does not upload
```

(Uploading requires the `central` server credentials in your `~/.m2/settings.xml`; CI injects
them from the secrets above.)

---

## Toolchain note

Both the DataWeave build plugin and the Central publishing plugin run on **JDK 17**, so the
entire pipeline uses a single JDK. If you bump the DataWeave toolchain versions in the pom,
re-verify `mvn clean test` on the CI JDK.
