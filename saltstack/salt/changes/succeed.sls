Step01:
  salt.state:
    - tgt: '*'
    - sls:
      - changes.pkg_succeed

