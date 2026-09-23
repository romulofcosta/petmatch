# unify-profile-creation

Consolidate user profile creation into a single source of truth: the create-profile Edge Function. Remove/bypass the duplicate RPC (create_user_profile) and the direct insert path in Flutter. Reserve SQL RPC for purely transactional operations.
