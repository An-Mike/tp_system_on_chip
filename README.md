# Tutoriel — Création d’un composant personnalisé Qsys

## Présentation

Ce projet montre comment créer un composant matériel personnalisé pour un système SoC (System-on-Chip) en utilisant Qsys / Platform Designer d’Intel-Altera.

L’objectif est de concevoir un registre 16 bits (`reg16`) accessible par un processeur Nios II via une interface Avalon Memory-Mapped (Avalon-MM).

Le composant est ensuite intégré dans un système embarqué complet sur FPGA comprenant :
- un processeur Nios II
- une mémoire interne (On-Chip Memory)
- un bus Avalon Interconnect
- un composant IP personnalisé
- des afficheurs 7 segments

---

## Composant personnalisé

Le composant est constitué de :
- `reg16.v` → registre matériel 16 bits
- `reg16_avalon_interface.v` → interface Avalon-MM du composant

Le composant permet :
- la lecture/écriture depuis le processeur
- la gestion du byte-enable
- l’export des données vers l’extérieur grâce à une interface Conduit

---

## Architecture du système

j'ai mis un schéma bloc de l'architecture sous le nom : "archi_attendu_tuto.png"

---

## Concepts étudiés

- Création d’un composant IP personnalisé Qsys
- Utilisation des interfaces Avalon-MM
- Communication matériel / logiciel
- Intégration d’un SoC sur FPGA
- Connexion d’un composant matériel au processeur Nios II

---

## Résultat final

À la fin du tutoriel, le processeur Nios II peut écrire des valeurs dans le registre personnalisé, et les données stockées sont affichées sur les afficheurs 7 segments de la carte FPGA.