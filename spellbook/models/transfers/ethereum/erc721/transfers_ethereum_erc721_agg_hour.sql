{{ config(
        alias ='erc721_agg_hour',
        materialized ='incremental',
        file_format ='delta',
        incremental_strategy='merge'
        )
}}

select
    'ethereum' as blockchain,
    date_trunc('hour', evt_block_time) as hour,
    wallet_address,
    token_address,
    tokenId
from {{ ref('transfers_ethereum_erc721') }}
{% if is_incremental() %}
-- this filter will only be applied on an incremental run
where evt_block_time > now() - interval 2 days
{% endif %}
group by
    date_trunc('hour', evt_block_time), wallet_address, token_address, tokenId
having sum(amount) = 1