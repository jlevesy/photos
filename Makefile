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

.PHONY: import
import: check_variables create_output_dirs album create_photos fill_index

.PHONY: album
album:
	hugo new $(ALBUM)/_index.md

.PHONY: fill_index
fill_index:
	@for file in $(FULL_DIR)/* ; do \
		echo "{{< photo full=\"full/$$(basename $${file})\" thumb=\"thumb/$$(basename $${file})\" alt=\"\" phototitle=\".\" description=\".\">}}" >> ./content/$(ALBUM)/_index.md; \
  done

.PHONY: create_photos
create_photos: $(THUMBS_OUTPUTS_JPG) $(THUMBS_OUTPUTS_PNG) $(FULL_OUTPUTS_JPG) $(FULL_OUTPUTS_PNG)

.PHONY: check_variables
check_variables:
	@test $(ALBUM)
	@test $(IMPORT_DIR)

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
