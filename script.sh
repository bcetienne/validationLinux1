#! /bin/bash

## COLORS
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
orange=`tput setaf 33`;
noColor=`tput sgr0`;

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

  if  [ "$choiceAction" == "installVagrant" ]
  then
    installVagrant;
  elif  [ "$choiceAction" == "installVB" ]
  then
    installVB;
  elif  [ "$choiceAction" == "vagrantMenu" ]
  then
    vagrantMenu;
  elif  [ "$choiceAction" == "quit" ]
  then
    echo "${green}A bientôt${noColor}";
    exit;
  fi
}

function installVagrant {
  echo "Recherche de Vagrant dans le système...";
  findPackage=$(dpkg-query -W --showformat='${Status}\n' vagrant|grep "install ok installed");

  if [ "" == "$findPackage" ]
  then
    echo "${magenta}Installation de Vagrant...${noColor}";
    wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb;
    sudo dpkg -i vagrant_2.1.1_x86_64.deb;
    echo "${magenta}Version de Vagrant :${noColor}";
    vagrant version;
  else 
    echo "${magenta}Vagrant est déjà installé, voulez-vous le désinstaller pour le réinstaller ? (y/n)${noColor}";
    read -rsn1 choicePackage;

    while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Voulez-vous désinstaller Vagrant pour le réinstaller ? (y/n)"
      read -rsn1 choicePackage;
    done

    if [ "$choicePackage" == "y" ]
    then
      echo "${magenta}Désinstallation de Vagrant...${noColor}";
      sudo apt-get remove --auto-remove vagrant;
      rm -r ~/.vagrant.d;

      echo "${magenta}Installation de Vagrant...${noColor}";
      wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb;
      sudo dpkg -i vagrant_2.1.1_x86_64.deb;
      echo "${magenta}Version de Vagrant :${noColor}";
      vagrant version;
    elif [ "$choicePackage" == "n" ]
    then
      mainMenu;
    fi
  fi
}

function installVirtualBox {
  echo "Recherche de VirtualBox dans le système...";
  findPackage=$(dpkg-query -W --showformat='${Status}\n' virtualbox|grep "install ok installed");

  if [ "" == "$findPackage" ]
  then
    echo "${magenta}Installation de VirtualBox...${noColor}";
    sudo apt-install virtualbox -y || echo "${red}Error : Damn, something went wrong bro...${noColor}" && mainMenu;
    sudo apt-install virtualbox-qt -y || echo "${red}Error : Damn, something went wrong for the second time bro ! Check your internet connection plz${noColor}" && mainMenu;
  else 
    echo "${magenta}VirtualBox est déjà installé, voulez-vous le désinstaller pour le réinstaller ? (y/n)${noColor}";
    read choicePackage;

    while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Voulez-vous désinstaller VirtualBox pour le réinstaller ? (y/n)"
      read -rsn1 choicePackage;
    done

    if [ "$choicePackage" == "y" ]
    then
      echo "${magenta}Désinstallation de VirtualBox...${noColor}";
      sudo apt-get remove --purge virtualbox;
      sudo rm ~/"VirtualBox VMs" -Rf;
      sudo rm ~/.config/VirtualBox/ -Rf;
      echo "${magenta}Installation de VirtualBox...${noColor}";
      sudo apt-install virtualbox -y || echo "${red}Error : Damn, something went wrong bro...${noColor}" && mainMenu;
    sudo apt-install virtualbox-qt -y || echo "${red}Error : Damn, something went wrong for the second time bro ! Check your internet connection plz${noColor}" && mainMenu;
    elif [ "$choicePackage" == "n" ]
    then
      mainMenu;
    fi
  fi
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
    elif [ "$choiceVagrant" == "listVagrant" ]
    then
      showVagrant;
    elif [ "$choiceVagrant" == "destroyVagrant" ]
    then
      destroyVagrant;
    elif [ "$choiceVagrant" == "return" ]
    then
      mainMenu;
    fi
}

function createVagrant {
  optionsOS=("ubuntu/xenial64" "ubuntu/trusty64" "hashicorp/precise64" "Retour");
  echo "${magenta}Choisissez un des OS ci-dessous :${noColor}";
  select responseOSMenu in "${optionsOS[@]}"
  do
    case $responseOSMenu in
      "ubuntu/xenial64" ) choiceOS="ubuntu/xenial64";break;;
      "ubuntu/trusty64" ) choiceOS="ubuntu/trusty64";break;;
      "hashicorp/precise64" ) choiceOS="hashicorp/precise64";break;;
      "Retour" ) choiceOS="return";break;; 
    esac
  done

  if [ "$choiceOS" == "ubuntu/xenial64" ]
  then
    os=$choiceOS;
    syncFile="";
    ipAddress="";

    echo "${magenta}Quel est le dossier de synchronisation que vous voulez créer ?${noColor}";
    read syncFile;
    mkdir $syncFile;

    echo "${magenta}Quelle est l'adresse ip que vous voulez assigner à la machine Vagrant ?${noColor}";
    read ipAddress;

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
    vagrant ssh -c "sudo apt update";

    echo "${magenta}Voulez-vous installer PHP ? (y/n)${noColor}";
    read -rsn1 choicePHP;

    while [ "$choicePHP" != "y" ] && [ "$choicePHP" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePHP;
    done

    if [ "$choicePHP" == "y" ]
    then
      vagrant ssh -c "sudo add-apt-repository ppa:ondrej/php";
      vagrant ssh -c "sudo apt update";
      vagrant ssh -c "sudo apt install -y unzip curl php7.2 php7.2-cli php7.2-mbstring php7.2-mysql libapache2-mod-php7.2 php7.2-xml php-mcrypt php7.2-intl php-curl php-zip php-gd";

      echo "${magenta}Voulez-vous installer Composer ? (y/n)${noColor}";
      read -rsn1 choiceComposer;

    while [ "$choiceComposer" != "y" ] && [ "$choiceComposer" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choiceComposer;
    done

      if [ "$choiceComposer" == "y" ]
      then
        vagrant ssh -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\"";
        vagrant ssh -c "php -r \"if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;\"";
        vagrant ssh -c "sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer\"";
        vagrant ssh -c "php -r \"unlink('composer-setup.php');\"";
        echo "${magenta}Composer a été installé avec succès.${noColor}";
      elif [ "$choiceComposer" == "n" ]
      then
        echo "${green}Eviter Composer${noColor}";
      fi
    elif [ "$choicePHP" == "n" ]
    then
      echo "${green}Eviter PHP${noColor}";
    fi

    echo "${magenta}Voulez-vous installer MySQL ? (y/n)${noColor}";
    read choiceMySQL;
    while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePackage;
    done

    if [ "$choiceMySQL" == "y" ]
    then
      vagrant ssh -c "export DEBIAN_FRONTEND=\"noninteractive\"";
      # Sets MySQL password to root without asking the user for it
      vagrant ssh -c "sudo debconf-set-selections <<< \"mysql-server mysql-server/root_password password root\"";
      vagrant ssh -c "sudo debconf-set-selections <<< \"mysql-server mysql-server/root_password_again password root\"";
      vagrant ssh -c "sudo apt install -y mysql-server";
      echo "${magenta}MySQL a été installé avec succès, l'utilisateur a été défini sur <<root>> et le mot de passe est <<root>>";
    elif [ "$choiceMySQL" == "n" ]
    then
      echo "${green}Eviter MySQL${noColor}";
    fi

    echo "${magenta}Voulez-vous installer Apache2 ? (y/n)${noColor}";
    read choiceApache2;
    while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePackage;
    done

    if [ "$choiceApache2" == "y" ]
    then
      vagrant ssh -c "sudo apt install -y apache2";
      vagrant ssh -c "sudo a2enmod rewrite";
      vagrant ssh -c "sudo apache2 reload";
      echo "${magenta}Apache2 a bien été installé${noColor}";
    elif [ "$choiceApache2" == "n" ]
    then
      echo "${green}Eviter Apache2${noColor}";
    fi

    echo "${magenta}Voulez-vous installer NodeJS ? (y/n)${noColor}";
    read choiceNode;
    while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePackage;
    done

    if [ "$choiceNode" == "y" ]
    then
      echo "${magenta}Installation de NodeJS${noColor}";
      vagrant ssh -c "curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh";
      vagrant ssh -c "sudo bash nodesource_setup.sh";
      vagrant ssh -c "sudo apt-get -y install nodejs";
      vagrant ssh -c "sudo apt-get -y install build-essential";
      vagrant ssh -c "sudo apt update";
      vagrant ssh -c "sudo apt upgrade -y";

      echo "${magenta}Voulez-vous installer MongoDB ? (y/n)${noColor}";
      read choiceMongo;
      while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePackage;
    done

      if [ "$choiceMongo" == "y" ]
      then
        echo "${magenta}Installation de MongoDB${noColor}";
        vagrant ssh -c "npm install mongodb --save";
      elif [ "$choiceMongo" == "n"]
      then
        echo "${green}Eviter MongoDB${noColor}";
      fi
      
      echo "${magenta}Voulez-vous installer ExpressJS ? (y/n)${noColor}";
      read choiceExpress;
      while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echo "Veuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePackage;
    done

      if [ "$choiceExpress" == "y" ]
      then
        echo "${magenta}Installation de ExpressJS${noColor}";
        vagrant ssh -c "npm install express";
      elif [ "$choiceExpress" == "n" ]
      then
        echo "${green}Eviter ExpressJS${noColor}";
      fi
    elif [ "$choiceNode" == "n" ]
    then
      echo "${green}Eviter NodeJS${noColor}";
    fi
    vagrant ssh -c "sudo apt upgrade -y";
    vagrantMenu;
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
  while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; do
      echoVeuillez resaisir une réponse correcte. (y/n)"
      read -rsn1 choicePackage;
    done

  elif [ "$choiceDestroy" == "y" ]
  then
    vagrant destroy $vagrantId;
    vagrantMenu;
  fi
}

function showVagrant {
  echo "${magenta}Affichage de toutes les machines Vagrant...${noColor}";
  vagrant global-status;
}

# TODO : Placer les erreurs dans un fichier error.log
function sendErrors {
  echo "zeub";
}
mainMenu;