$(1): PROJECT_ID = my_project_name
$(1): REGION = europe-west2
$(1): WORD_COUNTER_ENTRYPOINT = get_word_count


# Command to deploy preprocessing function
.PHONY: deploy_word_counter

$(eval $(call function_env, deploy_word_counter))
deploy_word_counter:
	@gcloud functions word-counter \
	    --project=$(PROJECT_ID) \
		--region=$(REGION) \
		--runtime=python39 \
		--source=function_word_counter \
		--entry-point=$(PROMPT_ARCHIVE_ENTRYPOINT) \
		--min-instances=0 \
		--max-instances=10 \
		--concurrency=1 \
		--memory=1Gi \
		--timeout=300s \
		--gen2 \
		--set-env-vars=GCP_PROJECT=$(PROJECT_ID)

