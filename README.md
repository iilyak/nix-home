# Installation

First you need to import your private pgp key
```
gpg --import private.key
```

Then you should be able to do the following
```
$ ln -s `pwd` ~/.config/nixpkgs
$ nix-env -f '<nixpkgs>' -iA home-manager
$ home-manager switch
```

# Adding secrets to securefs vault

```
bin/with-secrets cp mysecretfile ~/.config/secrets
```