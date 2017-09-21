#!/bin/bash

# Variables
SCRIPTS_DIR="./Scripts"
README="README.md"
README_TEMPLATE="${SCRIPTS_DIR}/README_template.md"
README_TMP="${SCRIPTS_DIR}/README_tmp.md"
cp $README_TEMPLATE $README_TMP 

# Remove Android content
echo "Removing Android content"
sed -i -e '
  /<android>/,/<\/android>/ {
    1 {
      s/^.*$//
      b
    }
    d
  }
' ${README_TMP}

#perl -0777pe 's/<android>.*<\/android>//smg' ${README_TMP}

# Enable iOS content
echo "Adding iOS content"
sed -i -e 's/<iOS>//g' ${README_TMP}
sed -i -e 's/<\/iOS>//g' ${README_TMP}

cp ${README_TMP} $README

rm ${SCRIPTS_DIR}/README_tmp*
