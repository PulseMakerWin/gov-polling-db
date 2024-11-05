CREATE OR REPLACE FUNCTION get_address_info(p_address TEXT)
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    column_name TEXT,
    id INT,
    address_value TEXT,
    amount NUMERIC,
    tx_id INT,
    block_id INT,
    additional_info JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH address_info AS (
        -- DSCHIEF.balances.address
        SELECT
            'dschief' AS schema_name,
            'balances' AS table_name,
            'address' AS column_name,
            b.id AS id,
            b.address::TEXT AS address_value,
            b.amount AS amount,
            b.tx_id AS tx_id,
            b.block_id AS block_id,
            NULL::JSONB AS additional_info
        FROM dschief.balances AS b
        WHERE b.address = p_address

        UNION ALL

        -- DSCHIEF.delegate_lock.from_address
        SELECT
            'dschief',
            'delegate_lock',
            'from_address',
            d.id,
            d.from_address::TEXT,
            NULL,
            d.tx_id,
            d.block_id,
            JSONB_BUILD_OBJECT('immediate_caller', d.immediate_caller::TEXT, 'contract_address', d.contract_address::TEXT) AS additional_info
        FROM dschief.delegate_lock AS d
        WHERE d.from_address = p_address

        UNION ALL

        -- DSCHIEF.delegate_lock.immediate_caller
        SELECT
            'dschief',
            'delegate_lock',
            'immediate_caller',
            d.id,
            d.immediate_caller::TEXT,
            NULL,
            d.tx_id,
            d.block_id,
            JSONB_BUILD_OBJECT('from_address', d.from_address::TEXT, 'contract_address', d.contract_address::TEXT) AS additional_info
        FROM dschief.delegate_lock AS d
        WHERE d.immediate_caller = p_address

        UNION ALL

        -- MKR.transfer_event.sender
        SELECT
            'mkr',
            'transfer_event',
            'sender',
            t.id,
            t.sender::TEXT,
            t.amount,
            t.tx_id,
            t.block_id,
            JSONB_BUILD_OBJECT('receiver', t.receiver::TEXT) AS additional_info
        FROM mkr.transfer_event AS t
        WHERE t.sender = p_address

        UNION ALL

        -- MKR.transfer_event.receiver
        SELECT
            'mkr',
            'transfer_event',
            'receiver',
            t.id,
            t.receiver::TEXT,
            t.amount,
            t.tx_id,
            t.block_id,
            JSONB_BUILD_OBJECT('sender', t.sender::TEXT) AS additional_info
        FROM mkr.transfer_event AS t
        WHERE t.receiver = p_address

        UNION ALL

        -- POLLING.voted_event.voter
        SELECT
            'polling',
            'voted_event',
            'voter',
            v.id,
            v.voter::TEXT,
            NULL,
            v.tx_id,
            v.block_id,
            JSONB_BUILD_OBJECT('poll_id', v.poll_id, 'option_id', v.option_id) AS additional_info
        FROM polling.voted_event AS v
        WHERE v.voter = p_address

        UNION ALL

        -- VULCAN2X.transaction.from_address
        SELECT
            'vulcan2x',
            'transaction',
            'from_address',
            tr.id,
            tr.from_address::TEXT,
            tr.value AS amount,
            tr.id AS tx_id,
            tr.block_id,
            JSONB_BUILD_OBJECT('to_address', tr.to_address::TEXT, 'hash', tr.hash::TEXT) AS additional_info
        FROM vulcan2x.transaction AS tr
        WHERE tr.from_address = p_address

        UNION ALL

        -- VULCAN2X.transaction.to_address
        SELECT
            'vulcan2x',
            'transaction',
            'to_address',
            tr.id,
            tr.to_address::TEXT,
            tr.value AS amount,
            tr.id AS tx_id,
            tr.block_id,
            JSONB_BUILD_OBJECT('from_address', tr.from_address::TEXT, 'hash', tr.hash::TEXT) AS additional_info
        FROM vulcan2x.transaction AS tr
        WHERE tr.to_address = p_address
    )
    SELECT *
    FROM address_info;
END;
$$ LANGUAGE plpgsql;
