
DIST_DIR := ./_dist
IMPORT_DIR := ./import
THUMBS_DIR := ./content/$(ALBUM)/thumb
FULL_DIR := ./content/$(ALBUM)/full

CONVERT := convert
FULL_SIZE := 1200x1200
THUMB_SIZE := 400x400
OUTPUT_FORMAT := jpg

IMPORTED_FILES_PNG := $(wildcard $(IMPORT_DIR)/*.png)
IMPORTED_FILES_JPG:= $(wildcard $(IMPORT_DIR)/*.jpg)

THUMBS_OUTPUTS_PNG := $(patsubst $(IMPORT_DIR)/%.png, $(THUMBS_DIR)/%.$(OUTPUT_FORMAT),$(IMPORTED_FILES_PNG))
FULL_OUTPUTS_PNG := $(patsubst $(IMPORT_DIR)/%.png,$(FULL_DIR)/%.$(OUTPUT_FORMAT),$(IMPORTED_FILES_PNG))
THUMBS_OUTPUTS_JPG := $(patsubst $(IMPORT_DIR)/%.jpg, $(THUMBS_DIR)/%.$(OUTPUT_FORMAT),$(IMPORTED_FILES_JPG))
FULL_OUTPUTS_JPG := $(patsubst $(IMPORT_DIR)/%.jpg, $(FULL_DIR)/%.$(OUTPUT_FORMAT),$(IMPORTED_FILES_JPG))

.PHONY: dev
dev:
	@hugo serve

.PHONY: build
build:
	@hugo -d $(DIST_DIR)

.PHONY: clean
clean:
	@rm -rf $(DIST_DIR)/*

.PHONY: deploy
deploy: clean build
	cd $(DIST_DIR) && git add --all && git commit -m "Deploying to gh-pages"
	git push origin gh-pages

.PHONY: setup_worktree
setup_worktree:
	git worktree add -B gh-pages $(DIST_DIR) origin/gh-pages

.PHONY: album
album: check_album_variable
	hugo new $(ALBUM)/_index.md

.PHONY: check_input_variable
check_input_variable:
	@test $(INPUT)

.PHONY: check_album_variable
check_album_variable:
	@test $(ALBUM)

import: check_album_variable create_output_dirs $(THUMBS_OUTPUTS_JPG) $(THUMBS_OUTPUTS_PNG) $(FULL_OUTPUTS_JPG) $(FULL_OUTPUTS_PNG)

.PHONY: create_output_dirs
create_output_dirs:
	@mkdir -p $(THUMBS_DIR)
	@mkdir -p $(FULL_DIR)

$(THUMBS_DIR)/%.$(OUTPUT_FORMAT): $(IMPORT_DIR)/%.png
	@echo Generating thumb png to png $@ $<
	@$(CONVERT) $< -resize $(THUMB_SIZE) $@

$(FULL_DIR)/%.$(OUTPUT_FORMAT): $(IMPORT_DIR)/%.png
	@echo Generating full image png to png $@ $<
	@$(CONVERT) $< -resize $(FULL_SIZE) $@

$(THUMBS_DIR)/%.$(OUTPUT_FORMAT): $(IMPORT_DIR)/%.jpg
	@echo Generating thumb jpg to png $@ $<
	@$(CONVERT) $< -resize $(THUMB_SIZE) $@

$(FULL_DIR)/%.$(OUTPUT_FORMAT): $(IMPORT_DIR)/%.jpg
	@echo Generating full jpg to png $@ $<
	@$(CONVERT) $< -resize $(FULL_SIZE) $@
