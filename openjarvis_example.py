#!/usr/bin/env python3
"""Exemple d'utilisation d'OpenJarvis avec Ollama pour l'Atelier des Écoliers."""

import sys
import time
from openjarvis import Jarvis


def ask(jarvis, question):
    """Pose une question et affiche la réponse avec le temps de réponse."""
    print(f"\n[Question] {question}")
    start = time.time()
    response = jarvis.ask(question)
    elapsed = time.time() - start
    print(f"[Réponse] {response}")
    print(f"[Temps] {elapsed:.1f}s")
    return response


def mode_interactif(jarvis):
    """Lance une boucle de conversation interactive."""
    print("\nMode interactif — tapez 'quit' pour quitter.\n")
    while True:
        try:
            question = input("Vous > ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if not question:
            continue
        if question.lower() in ("quit", "exit", "q"):
            break
        ask(jarvis, question)


def mode_demo(jarvis):
    """Exécute quelques questions de démonstration."""
    questions = [
        "Quelles activités créatives peut-on proposer à des enfants de 6 à 10 ans ?",
        "Donne-moi 3 idées d'ateliers manuels avec du matériel recyclé.",
        "Rédige un court texte de présentation pour un atelier créatif pour enfants.",
    ]
    for q in questions:
        ask(jarvis, q)


def main():
    model = "qwen2.5:1.5b"
    print(f"Initialisation d'OpenJarvis avec le modèle {model}...")

    jarvis = Jarvis(model=model)
    print("Prêt.")

    if "--interactif" in sys.argv or "-i" in sys.argv:
        mode_interactif(jarvis)
    else:
        mode_demo(jarvis)

    jarvis.close()
    print("\nTerminé.")


if __name__ == "__main__":
    main()
