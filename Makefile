.PHONY: help install format format-check analyze test test-flutter test-data check run clean

FLUTTER := flutter
DART := dart
PYTHON := python3

help:
	@echo ""
	@echo "🌱 PictoWord - commandes disponibles"
	@echo ""
	@echo "  make install       Installe les dépendances Flutter"
	@echo "  make format        Formate le code Dart"
	@echo "  make format-check  Vérifie le formatage sans modifier les fichiers"
	@echo "  make analyze       Analyse le code Dart"
	@echo "  make test-flutter  Lance les tests Flutter/Dart"
	@echo "  make test-data     Vérifie les données JSON avec Python"
	@echo "  make test          Lance tous les tests"
	@echo "  make check         Vérifie format + analyse + tests"
	@echo "  make run           Lance l'application"
	@echo "  make clean         Nettoie le projet Flutter"
	@echo ""

install:
	$(FLUTTER) pub get

format:
	$(DART) format .

format-check:
	$(DART) format --set-exit-if-changed .

analyze:
	$(FLUTTER) analyze

test-flutter:
	$(FLUTTER) test

test-data:
	$(PYTHON) tests/test_plantes.py

test:
	$(MAKE) test-data
	$(MAKE) test-flutter

check:
	$(MAKE) format-check
	$(MAKE) analyze
	$(MAKE) test

run:
	$(FLUTTER) run

clean:
	$(FLUTTER) clean