#! /bin/bash

## COLORS
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
orange=`tput setaf 33`;
noColor=`tput sgr0`;

# TODO : Faire le menu principal
function mainMenu {
  # Options lists
  options=("Installer Vagrant" "Installer VirtualBox" "Menu Vagrant" "Quitter");
  choiceVagrant="";
  echo "${yellow}Menu principal :${noColor}";
  select responseAction in "${options[@]}"
  do
    case $responseAction in
      "Installer Vagrant" ) choiceAction="installVagrant";break;;
      "Installer VirtualBox" ) choiceAction="installVB";break;;
      "Menu Vagrant" ) choiceAction="vagrantMenu";break;;
      "Quitter" ) choiceAction="quit";break;;
    esac
  done

  #if [ $choiceAction != "installVagrant" | $choiceAction != "installVB" | $choiceAction != "vagrantMenu" | $choiceAction != "quit" ]
  #then
  #  echo "Veuillez choisir une option dans le menu";
  #  mainMenu;
  #done

  if  [ "$choiceAction" == "installVagrant" ]
  then
    installVagrant;
  fi

  if  [ "$choiceAction" == "installVB" ]
  then
    installVB;
  fi

  if  [ "$choiceAction" == "vagrantMenu" ]
  then
    vagrantMenu;
  fi

  if  [ "$choiceAction" == "quit" ]
  then
    echo "${green}A bientôt${noColor}";
    exit;
  fi
}

# TODO : Installer Vagrant et/ou VirtualBox
function installVagrant {
  echo "${magenta}Désinstallation de l'ancienne version de Vagrant...${noColor}";
  sudo apt-get remove --auto-remove vagrant;
  rm -r ~/.vagrant.d;

  echo "${magenta}Installation de la nouvelle version de Vagrant...${noColor}";
  wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb;
  sudo dpkg -i vagrant_2.1.1_x86_64.deb;
  echo "${magenta}Version de Vagrant :${noColor}";
  vagrant version;
}

function installVirtualBox {
  echo "${magenta}Installation de VirtualBox...${noColor}";
  sudo apt-install virtualbox -y || echo "${red}Error : Damn, something went wrong bro...${noColor}" && mainMenu;
  sudo apt-install virtualbox-qt -y || echo "${red}Error : Damn, something went wrong for the second time bro ! Check your internet connection plz${noColor}" && mainMenu;
}

function vagrantMenu {
  echo "${yellow}Menu Vagrant :${noColor}"
  optionsVagrant=("Créer une machine virtuelle Vagrant" "Vagrant en cours" "Détruire une machine Vagrant" "Retour");
    select responseVagrantMenu in "${optionsVagrant[@]}"
    do
      case $responseVagrantMenu in
        "Créer une machine virtuelle Vagrant" ) choiceVagrant="createVagrant";break;;
        "Vagrant en cours" ) choiceVagrant="listVagrant";break;;
        "Détruire une machine Vagrant" ) choiceVagrant="destroyVagrant";break;;
        "Retour" ) choiceVagrant="return";break;; 
      esac
    done

    if [ "$choiceVagrant" == "createVagrant" ]
    then
      createVagrant;
    fi

    if [ "$choiceVagrant" == "listVagrant" ]
    then
      showVagrant;
    fi;

    if [ "$choiceVagrant" == "destroyVagrant" ]
    then
      destroyVagrant;
    fi

    if [ "$choiceVagrant" == "return" ]
    then
      mainMenu;
    fi
}

# TODO : Création d'une Vagrant comprenant le fichier VagrantFile
function createVagrant {
  optionsOS=("ubuntu/xenial64" "Retour");
  echo "${magenta}Choisissez un des OS ci-dessous :${noColor}";
  select responseOSMenu in "${optionsOS[@]}"
  do
    case $responseOSMenu in
      "ubuntu/xenial64" ) choiceOS="ubuntu/xenial64";break;;
      "Retour" ) choiceOS="return";break;; 
    esac
  done

  if [ "$choiceOS" == "ubuntu/xenial64" ]
  then
    os=$choiceAction;
    syncFile="";
    ipAddress="";

    echo "${magenta}Quelle est l'adresse ip que vous voulez assigner à la machine Vagrant ?${noColor}";
    read ipAddress;

    echo "${magenta}Quel est le dossier de synchronisation que vous voulez créer ?${noColor}";
    read syncFile;

    vagrant init $os;

    oldWord="# config.vm.network \"private_network\", ip: \"192.168.33.10\""; 
    newWord="config.vm.network \"private_network\", ip: \"${ipAddress}\"";  
    sed -i.bak "s@${oldWord}@${newWord}@g" ./Vagrantfile;

    oldWord2="# config.vm.synced_folder \"../data\", \"/vagrant_data\""; 
    newWord2="config.vm.synced_folder \"./${syncFile}\", \"/var/www/html/\"";
    sed -i.bak "s@${oldWord2}@${newWord2}@g" ./Vagrantfile;

    echo "${magenta}Configuration du fichier VagrantFile terminé, lancement de la machine...${noColor}";
    echo "${magenta}Installation de la machine, ceci peut prendre plus ou moins de temps en fonction de votre connexion à internet...${noColor}";

    vagrant up;
  
    echo "${magenta}Installation de PHP, Composer, MySQL et Apache...${noColor}";
    vagrant ssh -c "sudo add-apt-repository ppa:ondrej/php && sudo apt update && export DEBIAN_FRONTEND=\"noninteractive\" && sudo debconf-set-selections <<< \"mysql-server mysql-server/root_password password root\" && sudo debconf-set-selections <<< \"mysql-server mysql-server/root_password_again password root\" && sudo apt install -y mysql-server && sudo apt install -y apache2 unzip curl php7.2 php7.2-cli php7.2-mbstring php7.2-mysql libapache2-mod-php7.2 php7.2-xml php-mcrypt php7.2-intl php-curl php-zip php-gd && cd && php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && php -r \"if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;\" && sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer\" && php -r \"unlink('composer-setup.php');\" && sudo a2enmod rewrite && sudo apt update && sudo apt upgrade -y";
  fi

  if [ "$choiceOS" == "return" ]
  then
    vagrantMenu;
  fi
}

function destroyVagrant {
  vagrantId="";
  choiceDestroy="";
  showVagrant;
  echo "${magenta}Entrez l'id d'une machine Vagrant pour la détruire${noColor}"
  read vagrantId;
  
  echo "${magenta}Etes-vous sûr ? Cette action est irreversible (y/n)${noColor}";
  read choiceDestroy;

  if [ "$choiceDestroy" == "n" ]
  then
    vagrantMenu;
  fi

  if [ "$choiceDestroy" == "y" ]
  then
    vagrant destroy $vagrantId;
    vagrantMenu;
  fi
}

# TODO : Afficher les Vagrant en fonctionnement sur le système et interragir avec
function showVagrant {
  echo "${magenta}Affichage de toutes les machines Vagrant...${noColor}";
  vagrant global-status;
}

# TODO : Placer les erreurs dans un fichier error.log
function sendErrors {
  echo "zeub";
}

mainMenu;