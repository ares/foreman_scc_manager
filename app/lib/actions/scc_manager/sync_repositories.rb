module Actions
  module SccManager
    class SyncRepositories < Actions::EntryAction
      def plan(scc_account)
        action_subject(scc_account)
        plan_self(base_url: scc_account.base_url,
                  login: scc_account.login,
                  password: scc_account.password)
      end

      def run
        output[:status] = 'IN PROGRESS'
        begin
          output[:data] = ::SccManager.get_scc_data(input[:base_url],
                                                    '/connect/organizations/repositories',
                                                    input[:login],
                                                    input[:password])
          output[:status] = 'SUCCESS'
        rescue StandardError
          output[:status] = 'FAILURE'
        end
      end

      def finalize
        SccAccount.find(input[:scc_account][:id]).update_scc_repositories(output[:data]) if output[:status] == 'SUCCESS'
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Fail
      end

      def humanized_name
        _('Sync SUSE subscriptions (Repositories)')
      end

      def humanized_input
        input.dup.update(password: '***')
      end

      def humanized_output
        output.dup.update(data: "Trimmed (got #{output[:data]&.length} repositories")
      end
    end
  end
end
