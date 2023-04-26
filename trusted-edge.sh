TRUSTED_EDGE_REMOTE="${TRUSTED_EDGE_REMOTE:-34.82.233.186}"
TRUSTED_EDGE_USERNAME="${TRUSTED_EDGE_USERNAME:-onclaveit}"
TRUSTED_EDGE_SSH_KEY_FILENAME="${TRUSTED_EDGE_SSH_KEY_FILENAME:-precision-key.pem}"
GS_BUCKETNAME=m_lab
SRC="$HOME/data"
DST="${TRUSTED_EDGE_REMOTE}:/home/${TRUSTED_EDGE_USERNAME}/data"

inotifywait -qm --event create --format "%f" $SRC | \
	while read filename; do
		scp -i "$HOME/.ssh/$TRUSTED_EDGE_SSH_KEY_FILENAME" "${SRC}/${filename}" "${TRUSTED_EDGE_USERNAME}@${DST}/${filename}"
		ssh -i "$HOME/.ssh/$TRUSTED_EDGE_SSH_KEY_FILENAME" gsutil mv "${DST}/${filename}" "gs://${GS_BUCKETNAME}/${filename}"
	done

