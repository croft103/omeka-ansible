---
- hosts: p-w-omeka01.library.ucla.edu 
  become: true
  become_user: root
  become_method: sudo

  tasks:
    - name: Include vars
      include_vars:
        file: pkgs.yml
    - name: Enable rhscl repo
      command: >
        subscription-manager repos 
        --enable=rhel-server-rhscl-7-rpms
    - name: Install nodejs
      yum:
        name: nodejs
        state: latest
    - name: Install ImageMagick 
      yum:
        name: ImageMagick 
        state: installed
    - name: Install php56 from rhscl
      yum:
        name: "{{ php56_pkgs }}"
        state: installed
    - name: Install httpd24 from rhscl
      yum:
        name: "{{ httpd24_pkgs }}"
        state: installed
