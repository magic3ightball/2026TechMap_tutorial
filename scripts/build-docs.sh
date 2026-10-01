#!/usr/bin/env bash

set -euo pipefail

repository_root=$(cd "$(dirname "$0")/.." && pwd)
source_catalog="$repository_root/outputs/PlaneDetectionTutorial.docc"
theme_file="$repository_root/theme/apple-docc.css"
production_output="$repository_root/docs"
preview_output="$repository_root/outputs/PlaneDetectionTutorial.preview.doccarchive"

build_archive() {
    local output_path=$1
    local bundle_identifier=$2
    local base_path=${3:-}
    local build_directory
    local archive_path
    local stylesheet_path

    build_directory=$(mktemp -d)
    archive_path="$build_directory/archive"

    local arguments=(
        convert "$source_catalog"
        --fallback-display-name "Wall Excavation"
        --fallback-bundle-identifier "$bundle_identifier"
        --fallback-bundle-version "1.0"
        --transform-for-static-hosting
        --output-path "$archive_path"
    )

    if [[ -n "$base_path" ]]; then
        arguments+=(--hosting-base-path "$base_path")
        stylesheet_path="/$base_path/css/apple-docc.css"
    else
        stylesheet_path="/css/apple-docc.css"
    fi

    xcrun docc "${arguments[@]}"
    cp "$theme_file" "$archive_path/css/apple-docc.css"

    while IFS= read -r -d '' html_file; do
        perl -0pi -e "s#</head>#<link href=\"$stylesheet_path\" rel=\"stylesheet\"></head>#" "$html_file"
    done < <(find "$archive_path" -name index.html -print0)

    mkdir -p "$output_path"
    rsync -a --delete "$archive_path/" "$output_path/"
}

build_archive "$preview_output" "com.techmap.plane-excavation.preview"
build_archive "$production_output" "com.techmap.plane-excavation" "2026TechMap_tutorial"
: > "$production_output/.nojekyll"

echo "Built DocC archives."
