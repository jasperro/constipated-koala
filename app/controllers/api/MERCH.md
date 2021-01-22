# Merchandise
This document contains information regarding the merchandise endpoints.

`[POST] /api/merch/order`

Request body:
```json
{
    "orderId": "123-abc",
    "items": [
        {
            "item_entry_id": "aaa",
            "item_size": "M",
            "item_color": "Orange",
            "quantity": 3
        },
                {
            "item_entry_id": "bbb",
            "item_size": "L",
            "item_color": "Black",
            "quantity": 2
        }
    ]
}
```

Response body:
```json
{
    "order_id": "123-abc"
}
```

`[GET] /api/merch/order/:order_id`

Response body:
```json
[
    {
        "order_id": "1",
        "quantity": 2,
        "item_entry_id": "bbb",
        "item_size": "L",
        "item_color": "Black",
        "status": null,
        "member_id": 1,
        "created_at": "2021-01-22T20:21:14.174+01:00",
        "updated_at": "2021-01-22T20:21:14.174+01:00"
    },
    {
        "order_id": "1",
        "quantity": 3,
        "item_entry_id": "aaa",
        "item_size": "M",
        "item_color": "Orange",
        "status": null,
        "member_id": 1,
        "created_at": "2021-01-22T20:21:13.979+01:00",
        "updated_at": "2021-01-22T20:21:13.979+01:00"
    }
]
```