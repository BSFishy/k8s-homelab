# todos

miscellaneous things that i dont want to waste time now setting up but that i
need to have for long term security and stability. and also otherwise just cool
stuff and things

## miscellaneous

- [ ] fix pod security admission so no namespaces are privileged

## vault

- [ ] enable tls for vault. i initially disabled this because it was giving me
      404s but i think i can have internal stuff reference the cluster local addresses
- [ ] use the tf-controller to manage vault configurations. i have a bunch of
      stuff set up ad hoc right now and i don't like that.
- [ ] set up redis to use vault credentials. initially thought vault didnt have
      an engine for redis but it does, just not a ui
