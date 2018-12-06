---
- hosts: p-w-omeka01.library.ucla.edu 
  become: true
  become_user: root
  become_method: sudo
  vars:
#    mysql_databases:
#      - name: omeka_s
#        collation: utf8_bin
#        encoding: utf8
#        state: present
#    mysql_users:
#      - name: omeka_s_admin
#        host: localhost 
#        password: myOmekaPass 
#        priv: omeka_s.*:ALL
#        state: present
#    project_name: omeka_s
#    env_name: test 

#  roles:
# Prior to running this playbook, install MySQL vewrsion 5.6.41 by manually from rpms
# Using my own copy of uclalib_role_mysql which will not install version 5.6
# but will configure the installed version of MySQL.
#    - { role: uclalib_role_mysql, mysql_install_version: '5.6' } 

  tasks:
    - name: Post Omeka Install - Change ownership of Omeka files
      file:
        path: /opt/rh/httpd24/root/var/www/html/omeka-s/files
        recurse: yes
        owner: apache
        group: apache
    - name: Post Omeka Install - Copy database.ini 
      copy:
        src: files/database.ini
        dest: /opt/rh/httpd24/root/var/www/html/omeka-s/config/ 
        owner: root
        group: root
        mode: 0644
    - name: Post Install - Create logging directory
      file:
        path: /var/log/httpd24/omeka
        owner: root
        group: root
        state: directory
        mode: 0755
      notify:
      - restart httpd24-httpd 
    - name: Post Install - Copy httpd.conf
      copy:
        src: files/httpd.conf
        dest: /opt/rh/httpd24/root/etc/httpd/conf
        owner: root
        group: root
        mode: 0655
      notify:
      - restart httpd24-httpd 
    - name: Post Install - Copy ssl.conf
      copy:
        src: files/ssl.conf
        dest: /opt/rh/httpd24/root/etc/httpd/conf.d
        owner: root
        group: root
        mode: 0644
      notify:
      - restart httpd24-httpd 
    - name: Post Install - Create vhosts directory and copy files
      copy:
        src: "{{ item }}" 
        dest: /opt/rh/httpd24/root/etc/httpd/vhosts.d/
        owner: root
        group: root
        mode: 0644
      with_fileglob:
        - "files/vhosts/*"
      notify:
      - restart httpd24-httpd
    - name: Post Install - Copy certificate files 
      copy:
        src: "{{ item }}" 
        dest: /etc/pki/tls/certs/ 
        owner: root
        group: root
        mode: 0400
      with_fileglob:
        - "files/certs/*"
    - name: Post Install - Copy firewalld zone file
      copy:
        src: files/firewall/public.xml
        dest: /etc/firewalld/zones/
        owner: root
        group: root
        mode: 0644
      notify:
      - restart firewalld
    - name: Post Install - Copy firewalld service file
      copy:
        src: files/firewall/omeka.xml
        dest: /etc/firewalld/services/
        owner: root
        group: root
        mode: 0644
      notify:
      - restart firewalld
    - name: Post Install - Copy profile.d file 
      copy:
        src: files/enablephp56.sh
        dest: /etc/profile.d/ 
        owner: root
        group: root
        mode: 0644
    - name: Post Install - Enable httpd24-httpd and start
      systemd:
        name: httpd24-httpd
        enabled: yes
        state: started
  handlers:
    - name: restart firewalld
      service:
         name: firewalld
         state: restarted
    - name: restart httpd24-httpd
      service:
         name: httpd24-httpd
         state: restarted
